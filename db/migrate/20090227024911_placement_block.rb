class PlacementBlock < ActiveRecord::Migration
  def self.up
    add_column :placements, :block, :string
  end

  def self.down
    remove_column :placements, :block
  end
end
