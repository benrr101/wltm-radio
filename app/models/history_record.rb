class HistoryRecord < ApplicationRecord
  belongs_to :track
  has_many :skips, :dependent => :destroy

  def self.serializable_hash_options
    {
        :include => {:track => Track.serializable_hash_options},
        :except => [:track_id, :created_at, :updated_at]
    }
  end
end
