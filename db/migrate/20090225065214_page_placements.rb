class PagePlacements < ActiveRecord::Migration
  def self.up
    add_column :placements, :child_page_id, :integer
  end

  def self.down
    remove_column :placements, :child_page_id
  end
end
