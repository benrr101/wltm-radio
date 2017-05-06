class PersistentSettings < ApplicationRecord
  # CONSTANTS ##############################################################
  RoundRobinIdKey = 'roundRobinId'

  # STATIC METHODS #########################################################
  def self.preincrement_with_wrap(key, wrap)
    # Find the specified setting
    setting = self.find_by_key(key)
    return nil if setting.nil?

    # Store off the old value
    old_value = setting.value.to_i

    # Increment and set that as the new value
    setting.update(:value => (old_value + 1) % wrap)
    return old_value
  end
end