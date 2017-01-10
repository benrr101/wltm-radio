class Skip < ApplicationRecord
  belongs_to :history_record

  # @return [int] Number of votes to skip for the current track
  def self.current_skip_count
    begin
      current_history_id = HistoryRecord.last!.id
      Skip.where(:history_record_id => current_history_id).count
    rescue
      0
    end
  end

  # @return [float] Percentage of listeners who have voted to skip
  def self.current_skip_percentage
    current_listeners = IcecastStatus.get_status.current_listeners.to_i
    return 0 if current_listeners == 0  # Avoid div by zero errors

    self.current_skip_count.to_f / current_listeners.to_f * 100
  end

  # @returns [int] Threshold above which the current track will be skipped
  def self.skip_percentage_threshold
    return Rails.configuration.queues['skip_percentage']
  end
end
