class CounerAddTaskMax < ActiveRecord::Migration
  def self.up
    add_column :counters, :task_max, :integer, :default => 0
  end

  def self.down
    remove_column :counters, :task_max
  end
end
