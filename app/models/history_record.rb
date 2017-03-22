class HistoryRecord < ApplicationRecord
  belongs_to :track
  has_many :skips, :dependent => :destroy
end
