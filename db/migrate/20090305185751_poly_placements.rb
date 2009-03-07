class PolyPlacements < ActiveRecord::Migration
  def self.up
    add_column :placements, :child_item_type, :string
    add_column :placements, :child_item_id, :integer
  end

  def self.down
    remove_column :placements, :child_item_id
    remove_column :placements, :child_item_type
  end
end
