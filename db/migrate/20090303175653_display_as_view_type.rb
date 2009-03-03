class DisplayAsViewType < ActiveRecord::Migration
  def self.up
    rename_column :placements, :display, :view_type
  end

  def self.down
    rename_column :placements, :view_type, :display
  end
end
