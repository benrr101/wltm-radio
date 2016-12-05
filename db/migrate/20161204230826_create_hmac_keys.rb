class CreateHmacKeys < ActiveRecord::Migration[5.0]
  def change
    create_table :hmac_keys do |t|
      t.string  :public_key, :null => false, limit: 36
      t.string  :private_key, :null => false, limit: 36
      t.string  :description
    end

    add_index :hmac_keys, :public_key, :unique => true
    add_index :hmac_keys, :private_key, :unique => true
  end
end
