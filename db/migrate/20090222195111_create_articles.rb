class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title
      t.string :subtitle
      t.text :blurb
      t.text :body
      t.text :body_html
      t.string :status
      t.datetime :published_at
      t.integer :legacy_id
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps 
    end
  end

  def self.down
    drop_table :articles
  end
end
