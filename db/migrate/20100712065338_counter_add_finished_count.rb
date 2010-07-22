class CounterAddFinishedCount < ActiveRecord::Migration
  def self.up
    add_column :counters, :finished_tasks_num, :integer
    add_column :counters, :total_tasks_num, :integer
    Counter.find(:all).each{|c| c.calculate_current_tasks_num}
  end

  def self.down
    remove_column :counters, :finished_tasks_num
    remove_column :counters, :total_tasks_num
  end
end
