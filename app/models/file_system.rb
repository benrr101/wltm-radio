class FileSystem

  def self.get_all_shuffle_files

    # Generate a list of globbings to glob
    globbings = []
    Rails.configuration.files['included_folders'].each do |folder|
      folder = File.join(Rails.configuration.files['base_path'], folder)
      Rails.configuration.files['allowed_extensions'].each do |allowed_extension|
        glob = File.join(folder, '*.' + allowed_extension)
        globbings.push(glob)
      end
    end

    # Go through each folder and find the files that are allowed
    files_to_shuffle = []
    globbings.each do |glob|
      files_to_shuffle += Dir.glob(glob)
    end

    return files_to_shuffle

  end
end