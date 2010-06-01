class CountingTask < ActiveRecord::Base
  belongs_to :counter

  def set_result(result, time = nil)
    self.result = result
    self.time = time
    self.finished = true
    save
  end
  def result_array
    result.chomp.split(", ").collect{|x| x.to_i}
  end
end
