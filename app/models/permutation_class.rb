require 'auxiliary'
require 'permutations'
class PermutationClass < ActiveRecord::Base
  belongs_to :sequence
  def pattern_array
    patterns.to_string_array
  end
  def count(max = 7)
    s = self.sequence
    return unless s == nil or s.values.length < max
    results = count_avoiding(max, pattern_array)
    Sequence.add(results)
    self.sequence = Sequence.find_by_values(results)
  end
  def PermutationClass.exists?(patterns)
    find_by_patterns(patterns)
  end
  def PermutationClass.add(patterns)
#    patterns = patterns.inspect if Array === patterns
    patterns = patterns.to_string_array if String === patterns
    unless PermutationClass.exists?(patterns)
      PermutationClass.new do |pc|
          pc.patterns = patterns.join(", ")
          pc.count
          pc.save
      end
    end
  end
end
