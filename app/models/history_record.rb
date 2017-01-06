class HistoryRecord < ApplicationRecord
  belongs_to :track
  has_many :skips
end
