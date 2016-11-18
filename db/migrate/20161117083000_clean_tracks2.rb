class CleanTracks2 < ActiveRecord::Migration
  def up
    Track.where('title REGEXP ?', '\\[".*", ".*"\\]$').each do |track|
      say("Updating #{track.absolute_path}")
      captures = /\["(.*)", ".*"\]/.match(track.title).captures
      track.update!({:title => captures[0]})
    end
  end
end