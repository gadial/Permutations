class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.string :values_string
      t.string :counter_type, :default => "standard"
      t.integer :n
      t.integer :d, :default => 2
      t.integer :leaper_a, :default => 0
      t.integer :leaper_b, :default => 0
      t.integer :parallel_level, :default => 0
      t.integer :slices, :default => 1
      t.boolean :active, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :counters
  end
end
