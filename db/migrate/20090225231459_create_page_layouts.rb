class CreatePageLayouts < ActiveRecord::Migration
  def self.up
    create_table :page_layouts do |t|
      t.string :name
      t.text :html
      t.integer :legacy_id

      t.timestamps
    end
  end

  def self.down
    drop_table :page_layouts
  end
end
