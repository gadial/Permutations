require 'oeis'

class Sequence < ActiveRecord::Base
  has_many :permutation_classes
  def values
    values_string.to_number_array
  end
  def Sequence.find_by_values(vals)
    find_by_values_string(vals.inspect)
  end
  def init_description
    self.description = ask_the_oeis(values)
    self.checked = true if description != "error"
  end
  def Sequence.exists?(s)
    find_by_values_string(s)
  end
  def Sequence.add(s)
    s = s.inspect if Array === s
    unless Sequence.exists?(s)
      Sequence.new do |seq|
          seq.values_string = s
          seq.init_description
          seq.save
      end
    end
  end
end
