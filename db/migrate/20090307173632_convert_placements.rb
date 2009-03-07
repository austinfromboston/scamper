class ConvertPlacements < ActiveRecord::Migration
  def self.up
    #Placement.update_all [ "child_item_id = article_id and child_item_type = ?", "article" ], [ "article_id is not ?", nil ]
    #Placement.update_all [ "child_item_id = child_page_id and child_item_type = ?", "page" ], [ "child_page_id is not ?", nil ]
    remove_column :placements, :article_id
    remove_column :placements, :child_page_id
  end

  def self.down
    add_column :placements, :article_id, :integer
    add_column :placements, :child_page_id, :integer
    #Placement.update_all [ "article_id = child_item_id" ], [ "child_item_type = ?", "article" ]
    #Placement.update_all [ "child_page_id = child_item_id" ], [ "child_item_type = ?", "page" ]
  end
end
