require 'taglib'
require 'taglib/id3v1'
require 'taglib/id3v2'
require 'taglib/flac'
require 'taglib/aiff'
require 'taglib/ogg'
require 'taglib/wav'

class Track < ApplicationRecord
  belongs_to :art
  has_many :history_record, dependent: :destroy
  has_many :buffer_record, dependent: :destroy

  def Track.create_from_file(file_path)
    unless File.exists?(file_path)
      Rails.logger.warn("Failed to create track record: File does not exist #{file_path}")
      return nil
    end

    begin
      # Based on the extension of the file, load up the appropriate taglib handler
      tag_props = nil
      case File.extname(file_path).split('.').last
        when 'mp3', 'm4a'
          TagLib::MPEG::File.open(file_path) do |file|
            tag_props = {:tag => file.tag, :props => file.audio_properties}
          end
        when 'flac'
          TagLib::FLAC::File.open(file_path) do |file|
            tag_props = {:tag => file.tag, :props => file.audio_properties}
          end
        when 'ogg', 'oga'
          TagLib::Ogg::File.open(file_path) do |file|
            tag_props = {:tag => file.tag, :props => file.audio_properties}
          end
        when 'wav'
          TagLib::RIFF::WAV::File.open(file_path) do |file|
            tag_props = {:tag => file.tag, :props => file.audio_properties}
          end
        when 'aiff', 'aif', 'aifc'
          TagLib::RIFF::AIFF::File.open(file_path) do |file|
            tag_props = {:tag => file.tag, :props => file.audio_properties}
          end
        else
          TagLib::FileRef.open(file_path) do |file|
            tag_props = {:tag => file.tag, :props => file.audio_properties}
          end
      end

      # Attempt to get the art for the file
      #art_id = Art.create_from_file(file_path).id || nil

      # Using the tag file, get at the information we need to create the track
      track = Track.find_or_create_by!(absolute_path: file_path) do |track|
        track.artist = tag_props.nil? ? 'Unknown Artist' : tag_props[:tag].artist
        track.album = tag_props.nil? ? 'Unknown Album' : tag_props[:tag].album
        track.title = tag_props.nil? ? 'Uknonwn Title' : tag_props[:tag].title
        track.uploader = FileSystem::get_track_uploader(file_path)
        track.length = tag_props.nil? ? 0 : tag_props[:properties].length
        #track.art_id = art_id
      end
      Rails.logger.info("Adding new track #{file_path} from #{uploader}")
      return track
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