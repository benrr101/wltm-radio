require 'taglib'
require 'taglib/id3v1'
require 'taglib/id3v2'
require 'taglib/flac'
require 'taglib/aiff'
require 'taglib/ogg'
require 'taglib/wav'

class Art < ApplicationRecord
  has_many :track

  def self.create_from_file(path)
    # Step 1: Get the image file to store
    # Attempt 1: Load the art from the metadata
    mimetype = nil
    bytes = nil
    case File.extname(path).split('.').last
      when 'mp3', 'm4a'
        id3v2_tag = TagLib::MPEG::File.new(path).id3v2_tag
        if id3v2_tag.frame_list('APIC').any?
          pic = id3v2_tag.frame_list('APIC').first
          mimetype = pic.mime_type
          bytes = pic.picture
        end
      when 'flac'
        tag_file = TagLib::FLAC::File.new(path)
        unless tag_file.picture_list[0].nil?
          pic = tag_file.picture_list[0]
          mimetype = pic.mime_type
          bytes = pic.data
        end
      else
        mimetype = nil
        bytes = nil
    end

    # Attempt 2: Find any image files in the folder
    if mimetype.nil?
      image_files = FileSystem.get_all_image_files(path)
      if image_files.any?
        image_file = image_files[0]
        mimetype = FileSystem.get_image_mimetype(image_file)
        bytes = open(image_file, 'rb') { |file| file.read }
      end
    end

    # If we *still* don't have an image, just give up
    if mimetype.nil?
      return nil
    end

    # Step 2: Calculate the hash of the image bytes
    hash = Digest::SHA256.hexdigest(bytes)

    # Step 3: Store the image in the database
    begin
      Art.find_or_create_by!(hash_code: hash) do |art|
        art.mimetype = mimetype
        art.bytes = bytes
      end
    rescue e
      puts e
    end
  end

  def art_link
    "/api/art/#{hash_code}"
  end

end