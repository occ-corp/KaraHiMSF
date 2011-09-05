class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string   :login            , :limit => 40
      t.string   :name             , :limit => 100, :default => '', :null => true
      t.string   :kana
      t.string   :code
      t.integer  :qualification_id
      t.integer  :item_group_id
      t.string   :email            , :limit => 100
      t.string   :crypted_password , :limit => 40
      t.string   :salt             , :limit => 40
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :remember_token   , :limit => 40
      t.datetime :remember_token_expires_at
      t.string   :belong_code
      t.string   :current_belong_code
      t.string   :division_code
    end
    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
