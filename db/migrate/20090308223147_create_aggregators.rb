class CreateAggregators < ActiveRecord::Migration
  def self.up
    create_table :aggregators do |t|
      t.string :name
      t.text :logic
      t.integer :page_id

      t.timestamps
    end

    create_table :aggregation_sources do |t|
      t.integer :aggregator_id, :page_id
    end
  end

  def self.down
    drop_table :aggregation_sources
    drop_table :aggregators
  end
end
