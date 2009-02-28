class TreeOrder < ActiveRecord::Migration
  def self.up
    add_column :pages, :tree_order, :integer
  end

  def self.down
    remove_column :pages, :tree_order
  end
end
