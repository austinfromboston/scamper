class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :name
      t.string :url
      t.string :redirect_to
      t.string :tag
      t.integer :parent_page_id
      t.integer :legacy_id
      t.text :metakeywords
      t.text :metadescription

      t.timestamps 
    end
  end

  def self.down
    drop_table :pages
  end
end
