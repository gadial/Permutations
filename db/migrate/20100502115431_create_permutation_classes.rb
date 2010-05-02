class CreatePermutationClasses < ActiveRecord::Migration
  def self.up
    create_table :permutation_classes do |t|
      t.string  :patterns
      t.integer :sequence_id

      t.timestamps
    end
  end

  def self.down
    drop_table :permutation_classes
  end
end
