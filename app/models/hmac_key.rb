class HmacKey < ApplicationRecord

  # Determines if the headers are valid
  # @param [Array<String>] headers HTTP headers from the request
  # @param [String] raw_post The raw content of the request
  # @return [Boolean] True if the headers are valid, false otherwise
  def self.validate(headers, raw_post)
    # Check for the auth headers
    # @type [String]
    auth_header = headers['AUTHORIZATION']
    if auth_header.nil?
      yield('AUTHORIZATION header is required', :unauthorized)
      return false
    end

    # Make sure that the auth tokens are properly provided
    # @type [Array<String>]
    auth_tokens = auth_header.split(':')
    unless auth_tokens.size == 2
      yield('AUTHORIZATION header is malformed. Expected format like public:hash', :unauthorized)
      return false
    end

    # Calculate the expected HMAC and validate it
    unless HmacKey.validate_hash(auth_tokens[0], raw_post, auth_tokens[1])
      yield('Invalid authorization header. Either hash or public key is invalid.', :unauthorized)
      return false
    end

    # Request is validated
    return true
  end

  # PRIVATE HELPERS ########################################################
  private

  # Calculates a hash and validates it against the given hash
  # @param [String] public_key The public key to use to lookup the private key for hash generation
  # @param [String] message The raw message provided by the post command
  # @param [String] given_hash The hash provided in the authorization header
  # @return [Boolean] true if the hash is valid, false otherwise
  def self.validate_hash(public_key, message, given_hash)
    # Validate that the public key exists, otherwise return false
    key_record = self.find_by_public_key(public_key)
    return false if key_record == nil

    # Generate the hash for the message
    message_to_hash = "#{message}#{message.length}#{key_record.private_key}"

    return Digest::SHA256.hexdigest(message_to_hash) == given_hash
  end

end
