class CreateCountingTasks < ActiveRecord::Migration
  def self.up
    create_table :counting_tasks do |t|
      t.string :cmd
      t.string :result, :default => nil
      t.boolean :finished, :default => false
      t.integer :priority, :default => 0
      t.integer :counter_id
      t.float :time
      
      t.timestamps
    end
  end

  def self.down
    drop_table :counting_tasks
  end
end
