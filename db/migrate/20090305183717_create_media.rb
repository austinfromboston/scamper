class CreateMedia < ActiveRecord::Migration
  def self.up
    create_table :media do |t|
      t.string :caption
      t.string :alt_text
      t.string :license
      t.string :added_by
      t.date :media_created_on

      t.string :image_file_name, :image_content_type, :image_file_size
      t.datetime :image_updated_at
      t.integer :legacy_id

      t.timestamps 
    end
  end

  def self.down
    drop_table :media
  end
end
