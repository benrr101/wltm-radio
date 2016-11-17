class CleanTracks < ActiveRecord::Migration
  def up
    Track.where('title REGEXP ?', '\\[".*", ".*"\\]$').each do |track|
      captures = /\["(.*)", ".*"\]/.match(track.title).captures
      track.update!({:title => captures[0]})
    end
  end
end