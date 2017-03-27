require 'sys/filesystem'

class FileSystem

  # Status of the filesystem space usage
  class Status

    # Initializes a Status class by calculating the
    # @param [Sys::Filesystem::Stat] stat Statistics object from sys/filesystem
    def initialize(stat)
      @total_gb = stat.blocks * stat.block_size / 1024 / 1024 / 1024
      @free_gb = stat.blocks_free * stat.block_size / 1024 / 1024 / 1024
      @inuse_gb = (stat.blocks - stat.blocks_free) * stat.block_size / 1024 / 1024 / 1024

      @inuse_percent = @inuse_gb.to_f / @total_gb * 100.0
      @inuse_percent = @inuse_percent.round(1)
      @free_percent = 100 - @inuse_percent
    end

    # @return [int] Total number of GB for the base path
    def total_gb
      @total_gb
    end

    # @return [int] Number of GB free for the base path
    def free_gb
      @free_gb
    end

    # @return [int] Number of GB in use for the base path
    def inuse_gb
      @inuse_gb
    end

    # @return [float] Percentage of base path in use
    def inuse_percent
      @inuse_percent
    end

    # @return [float] Percentage of base path free
    def free_percent
      @free_percent
    end

  end

  # CLASS VARIABLES ########################################################
  @@base_folder_selection = 0

  # CLASS METHODS ##########################################################

  # A mimetype to default to if everything fails
  def self.default_mimetype
    return 'application/octet-stream'
  end

  # Retrieve statistics about free space
  # @return [FileSystem::Stats] Statistics about the space used on the base path
  def self.get_status
    # Get the stats for the root of the installation
    stat = Sys::Filesystem.stat(Rails.configuration.files['base_path'])
    return FileSystem::Status.new(stat)
  end

  # Retrieves all folders that files can be pulled from
  # @return [Array[string]] Array of folder paths to pull from
  def self.get_all_folders
    Rails.cache.fetch('filesystem/folders', expires_in: 1.hours) do
      # Glob the base folders
      base_folders = []
      Rails.configuration.files['included_folders'].each do |folder|
        folder = File.join(Rails.configuration.files['base_path'], folder)
        base_folders += Dir.glob(folder)
      end
      base_folders
    end
  end

  # Determines what files should be included in the shuffle
  # @return [Array[string]] An array of strings that should be shuffled
  def self.get_all_shuffle_files
    # Select the base folder for this selection
    base_folders = self.get_all_folders
    selected_base_folder = base_folders[@@base_folder_selection]
    @@base_folder_selection = (@@base_folder_selection + 1) % base_folders.length
    Rails.logger.debug("Picking file from selected base folder #{@@base_folder_selection} #{selected_base_folder}")

    # Generate globs for the different filetypes
    files_to_shuffle = []
    Rails.configuration.files['allowed_extensions'].each do |allowed_extension|
      glob = File.join(selected_base_folder, "**/*.#{allowed_extension}")
      files_to_shuffle += Dir.glob(glob)
    end

    return files_to_shuffle
  end

  # Fetches a list of all tracks that are in a given folder
  # @param folder [string]  The absolute path of the folder to get all tracks from
  # @return [Array[string]] An arry of all files in the folder
  def self.get_all_folder_files(folder)
    # Generate files that are in the folder
    files = []
    Rails.configuration.files['allowed_extensions'].each do |allowed_extension|
      glob = File.join(folder, "*.#{allowed_extension}")
      files += Dir.glob(glob)
    end

    return files
  end

  # Fetches a list of all images in the folder of a given audio file
  # @param folder [string]  The absolute path of the audio file to get images from
  # @return [Array[string]]  An array of all images files in the folder that contains the audio
  def self.get_all_image_files(audio_path)
    # Figure out which folder the audio is in
    folder = File.dirname(audio_path)

    # Generate files that are in the folder
    files = []
    Rails.configuration.files['allowed_image_extensions'].each do |allowed_extension|
      glob = File.join(folder, "*.#{allowed_extension}")
      files += Dir.glob(glob)
    end

    return files
  end

  # Attempts to determine the mimetype of the given image based on extension
  # @param image_path [string] Absolute path to the audio file
  # @return [string] The mimetype based on the file's extension
  def self.get_image_mimetype(image_path)
    return self.get_extension_mimetype(File.extname(image_path).split('.').last)
  end

  # Attempts to determine the mimetype based on the extension provided
  # @param extension [string] The string for the extension to determine the mimetype of
  # @return [string] The mimetype based on the extension
  def self.get_extension_mimetype(extension)
    case extension
      when 'png', 'PNG'
        return 'image/png'
      when 'jpg', 'JPG', 'jpeg', 'JPEG'
        return 'image/jpeg'
      when 'bmp', 'BMP'
        return 'image/bmp'
      when 'gif', 'GIF'
        return 'image/gif'
      else
        return self.default_mimetype
    end
  end

  # Calculates the uploader of the track
  # @param path [string]  The absolute path of the track
  # @return [string]  The uploader of the track
  def self.get_track_uploader(path)
    # Strip off the base path
    working_path = path.sub(Rails.configuration.files['base_path'], '')

    # Strip off any leading slash
    working_path.sub!(/^#{File::Separator}/, '')

    # Take the first split folder as the uploader
    return working_path.split(File::Separator)[0]
  end
end