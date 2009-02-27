class PageLayouts < ActiveRecord::Migration
  def self.up
    add_column :pages, :page_layout_id, :integer
  end

  def self.down
    remove_column :pages, :page_layout_id
  end
end
