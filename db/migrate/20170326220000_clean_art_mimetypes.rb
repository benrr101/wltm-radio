class CleanArtMimetypes < ActiveRecord::Migration
  def change
    # Iterate over the art
    Art.find_each(batch_size: 20) do |art|
      unless art.mimetype.include?('/')
        art.update_attributes(:mimetype => FileSystem.get_extension_mimetype(art.mimetype))
      end
      if art.mimetype.include?('(null)')
        art.update_attributes(:mimetype => FileSystem.default_mimetype)
      end
    end
  end
end

