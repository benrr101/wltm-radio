class Track < ApplicationRecord
  has_many :history_record

  def download_link
    # Skip generating a download link if we don't have a base path
    if Rails.configuration.files['base_download_path'].nil?
      return nil
    end

    # Figure out which folder this came from and remove it from the start
    working_path = share_path

    # This working path should be the path to add to the download base
    URI.join(Rails.configuration.files['base_download_path'], working_path).to_s
  end

  def folder_download_link
    # Skip generating a folder download link if we don't have a base path
    if Rails.configuration.files['base_folder_download_path'].nil?
      return nil
    end

    working_path = share_path
    URI.join(Rails.configuration.files['base_folder_download_path'], working_path).to_s
  end

  private
  def share_path
    # Figure out the path of the shared folder
    base_folder = FileSystem.get_all_folders.find do |folder|
      absolute_path.start_with?(folder)
    end

    # Trim base folder and leading / from absolute path
    base_folder = File.dirname(base_folder)
    URI.encode(absolute_path.sub(base_folder, '').sub('/', ''))
  end
end