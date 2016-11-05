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

  # Retrieve statistics about free space
  # @return [FileSystem::Stats] Statistics about the space used on the base path
  def self.get_status
    # Get the stats for the root of the installation
    stat = Sys::Filesystem.stat(Rails.configuration.files['base_path'])
    return FileSystem::Status.new(stat)
  end

  # Determines what files should be included in the shuffle
  # @return [Array[string]] An array of strings that should be shuffled
  def self.get_all_shuffle_files

    # Glob the base folders
    base_folders = []
    Rails.configuration.files['included_folders'].each do |folder|
      folder = File.join(Rails.configuration.files['base_path'], folder)
      base_folders += Dir.glob(folder)
    end

    # Select the base folder for this selection
    @@base_folder_selection
    selected_base_folder = base_folders[@@base_folder_selection]
    @@base_folder_selection = (@@base_folder_selection + 1) % base_folders.length
    Rails.logger.debug("Picking file from selected base folder #{@@base_folder_selection} #{selected_base_folder}")

    # Generate globs for the different filetypes
    globbings = []
    Rails.configuration.files['allowed_extensions'].each do |allowed_extension|
      glob = File.join(selected_base_folder, "**/*.#{allowed_extension}")
      globbings.push(glob)
    end

    # Go through each folder and find the files that are allowed
    files_to_shuffle = []
    globbings.each do |glob|
      files_to_shuffle += Dir.glob(glob)
    end

    return files_to_shuffle

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