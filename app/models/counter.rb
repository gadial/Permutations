require 'auxiliary'
require 'polyominoes'
class Counter < ActiveRecord::Base
  has_many :counting_tasks

  validates_presence_of :n
  
  def cmd(slice_start, slice_end)
    cmd_line = "./polyominocounter"
    cmd_line += " -n #{n}"
    cmd_line += " -d #{d}" if d and d != 2
    cmd_line += " -t 0" if counter_type == "standard"
    cmd_line += " -t 1" if counter_type == "leaper"
    cmd_line += " -p #{parallel_level}"
    cmd_line += " -s #{slice_start}"
    cmd_line += " -r #{slice_end}"
    cmd_line += " -a #{leaper_a}" if leaper_a
    cmd_line += " -b #{leaper_b}" if leaper_b
    cmd_line
  end

  def create_tasks
    task_max = RedelmeierAlgorithm.new(:n => parallel_level, :d => d, :type => counter_type.to_sym, :leaper_a => leaper_a, :leaper_b => leaper_b).run.results.last
    tasks_numbers = (0..task_max).to_a.slice(slices)
    puts tasks_numbers.inspect
    for t in tasks_numbers do
      CountingTask.new do |task|
        task.cmd = cmd(t.first, t.last)
        task.counter = self
        task.save
      end
    end
  end

  def inspect
    "Counter for n = #{n}, d = #{d}, type = #{counter_type}, with #{slices} slices starting at parallel level #{parallel_level}"
  end

  def get_counting_task
    task = counting_tasks.reject{|t| t.finished}.min_by { |t| t.priority }
    return nil unless task
    task.priority += 1
    task.save
    return task
  end

  def percent_done
    100*counting_tasks.find_all{|t| t.finished}.length / counting_tasks.length
  end

  def results
    counting_tasks.reject{|t| not t.finished}.collect{|t| t.result_array}.inject([0]*n){|sum, v| v.vector_partial_sum(sum, parallel_level,v.length - 1)}
  end

  def time
    counting_tasks.reject{|t| not t.finished}.collect{|t| t.time}.sum
  end
end

