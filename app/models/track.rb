require 'taglib'
require 'taglib/id3v1'
require 'taglib/id3v2'
require 'taglib/flac'
require 'taglib/aiff'
require 'taglib/ogg'
require 'taglib/wav'

class Track < ApplicationRecord
  belongs_to :art
  has_many :history_record
  has_many :buffer_record

  def Track.create_from_file(file_path)
    # Based on the extension of the file, load up the appropriate taglib handler
    case File.extname(file_path).split('.').last
      when 'mp3', 'm4a'
        tag_file = TagLib::MPEG::File.new(file_path)
      when 'flac'
        tag_file = TagLib::FLAC::File.new(file_path)
      when 'ogg', 'oga'
        tag_file = TagLib::Ogg::File.new(file_path)
      when 'wav'
        tag_file = TagLib::RIFF::WAV::File.new(file_path)
      when 'aiff', 'aif', 'aifc'
        tag_file = TagLib::RIFF::AIFF::File.new(file_path)
      else
        tag_file = TagLib::FileRef.new(file_path)
    end
    tag = tag_file.tag
    properties = tag_file.audio_properties

    # Using the tag file, get at the information we need to create the track
    return Track.find_or_create_by!(absolute_path: file_path) do |track|
      track.artist = tag.artist || 'Unknown Artist'
      track.album = tag.artist || 'Unknown Album'
      track.title = tag.artist || 'Uknonwn Title'
      track.uploader = FileSystem::get_track_uploader(file_path)
      track.length = properties.length
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