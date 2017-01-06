class CreateSkips < ActiveRecord::Migration[5.0]
  def change
    create_table :skips do |t|
      t.string :on_behalf_of

      t.timestamps
    end

    # Create references from skips -> history_records
    add_reference :skips, :history_record, index: true
    add_foreign_key :skips, :history_records
  end
end
