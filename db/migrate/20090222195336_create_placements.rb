class CreatePlacements < ActiveRecord::Migration
  def self.up
    create_table :placements do |t|
      t.integer :article_id
      t.integer :page_id
      t.integer :list_order
      t.string :display
      t.boolean :canonical

      t.timestamps 
    end
  end

  def self.down
    drop_table :placements
  end
end
