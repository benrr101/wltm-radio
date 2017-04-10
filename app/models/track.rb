require 'taglib'
require 'taglib/id3v1'
require 'taglib/id3v2'
require 'taglib/flac'
require 'taglib/aiff'
require 'taglib/ogg'
require 'taglib/wav'

class Track < ApplicationRecord
  belongs_to :art, optional: true
  has_many :history_record, dependent: :destroy
  has_many :buffer_record, dependent: :destroy

  def Track.create_from_file(file_path)
    unless File.exists?(file_path)
      Rails.logger.warn("Failed to create track record: File does not exist #{file_path}")
      return nil
    end

    begin
      # Based on the extension of the file, load up the appropriate taglib handler
      reader_method = nil
      case File.extname(file_path).split('.').last
        when 'mp3', 'm4a'
          reader_method = TagLib::MPEG::File.method(:open)
        when 'flac'
          reader_method = TagLib::FLAC::File.method(:open)
        when 'ogg', 'oga'
          reader_method = TagLib::Ogg::File.method(:open)
        when 'wav'
          reader_method = TagLib::RIFF::WAV::file.method(:open)
        when 'aiff', 'aif', 'aifc'
          reader_method = TagLib::RIFF::AIFF::File.method(:open)
        else
          reader_method = TagLib::FileRef.method(:open)
      end

      # Using the tag file, get at the information we need to create the track
      return Track.find_or_create_by!(absolute_path: file_path) do |track_obj|
        uploader = FileSystem::get_track_uploader(file_path)

        Rails.logger.info("Adding new track #{file_path} from #{uploader}")
        reader_method.call(file_path) do |tag_obj|
          track_obj.artist = tag_obj.tag.nil? ? 'Unknown Artist' : tag_obj.tag.artist
          track_obj.album = tag_obj.tag.nil? ? 'Unknown Album' : tag_obj.tag.album
          track_obj.title = tag_obj.tag.nil? ? 'Unknown Title' : tag_obj.tag.title
          track_obj.uploader = uploader
          track_obj.length = tag_obj.audio_properties.nil? ? 0 : tag_obj.audio_properties.length

          art = Art.create_from_file(file_path)
          track_obj.art_id = art.nil? ? nil : art.id
        end
      end
    rescue => e
      Rails.logger.warn("Failed to read track metadata #{file_path}: #{e}")
      return nil
    end
  end

  def download_link
    # Skip generating a download link if we don't have a base path
    if Rails.configuration.files['base_download_path'].nil?
      return nil
    end

    # Figure out which folder this came from and remove it from the start
    working_path = share_path
    if working_path.nil?
      return nil
    end

    # This working path should be the path to add to the download base
    URI.join(Rails.configuration.files['base_download_path'], working_path).to_s
  end

  def folder_download_link
    # Skip generating a folder download link if we don't have a base path
    if Rails.configuration.files['base_folder_download_path'].nil?
      return nil
    end

    working_path = share_path
    if working_path.nil?
      return nil
    end

    URI.join(Rails.configuration.files['base_folder_download_path'], working_path).to_s
  end

  private
  def share_path
    # Figure out the path of the shared folder
    base_folder = FileSystem.get_all_folders.find do |folder|
      absolute_path.start_with?(folder)
    end

    if base_folder.nil?
      return nil
    end

    # Trim base folder and leading / from absolute path
    base_folder = File.dirname(base_folder)
    URI.encode(absolute_path.sub(base_folder, '').sub('/', '')).gsub('[','%5B').gsub(']','%5D')
  end
end