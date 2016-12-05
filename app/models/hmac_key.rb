class HmacKey < ApplicationRecord
  def self.validate_hash(public_key, message, given_hash)
    # Validate that the public key exists, otherwise return false
    key_record = self.find_by_public_key(public_key)
    return false if key_record == nil

    # Generate the hash for the message
    message_to_hash = "#{message}#{message.length}#{key_record.private_key}"

    return Digest::SHA256.hexdigest(message_to_hash) == given_hash
  end
end
