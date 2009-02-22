class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.string :perishable_token
      t.integer :login_count
      t.integer :failed_login_count

      t.timestamps 
    end
  end

  def self.down
    drop_table :users
  end
end