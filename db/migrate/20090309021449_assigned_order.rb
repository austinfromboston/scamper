class AssignedOrder < ActiveRecord::Migration
  def self.up
    add_column :placements, :assigned_order, :integer
  end

  def self.down
    remove_column :placements, :assigned_order
  end
end
