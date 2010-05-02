class CreateSequences < ActiveRecord::Migration
  def self.up
    create_table :sequences do |t|
      t.string :values_string
      t.string :description
      t.boolean :checked, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :sequences
  end
end
