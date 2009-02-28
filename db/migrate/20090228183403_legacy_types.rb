class LegacyTypes < ActiveRecord::Migration
  def self.up
    add_column :pages, :legacy_type, :string, :limit => 20
    add_column :articles, :legacy_type, :string, :limit => 20
    add_column :page_layouts, :legacy_type, :string, :limit => 20
  end

  def self.down
    remove_column :page_layouts, :legacy_type
    remove_column :articles, :legacy_type
    remove_column :pages, :legacy_type
  end
end
