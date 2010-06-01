def all_choices_of_integers(n,k)
    return (0...n).collect{|x| [x]} if k == 1
    result = []
    ((k-1)...n).each{|x| result += all_choices_of_integers(x,k-1).collect{|t| t+[x]}}
    return result
end


class String
  def indices(pattern)
      result = [-1]
      while result.last != nil
        result << index(pattern,result.last+1)
      end
      return result[1..-2]
  end
  def inject(w,c)
      possible_injections = indices(c)
      result = []
      possible_injections.each do |i|
        new_str = dup
        new_str.insert(i,c+w)
        result << new_str
      end
      return result
    end
    def multiple_injection(w_array,c)
      return self if w_array.empty?
      return inject(w_array.first, c).collect{|s| s.multiple_injection(w_array[1..-1],c)}.flatten
    end

    def to_number_array
      self=~/\[?(.*)\]?/
      $1.split(/, |,/).collect{|x| x.to_i}
    end
    def to_string_array
      self.split(/, |,/).collect{|x| x=~/"?(.*)"?/; $1}
    end
    def replace_by_order(arr)
      result = self.dup
      places = (1..arr.length).collect{|i| index(i.to_s)}
      places.each_index{|i| result[places[i]] = arr[i].to_s}
      result
    end
end

class Array
  def all_permutations
		return [[]] if empty?
		sort.inject([]){|sum,x| sum += (self-[x]).all_permutations.collect{|p| p.unshift(x)}}
	end
	def union
	  result = []
	  each {|x| result += x}
	  result.uniq
	end

	def all_choices_with_repetitions(k)
		return collect{|x| [x]} if k == 1
		result = []
		each {|x| result += all_choices_with_repetitions(k-1).collect{|t| t+[x]}}
		return result
	end
  def all_choices_without_repetitions(k)
      all_choices_of_integers(length,k).collect{|t| t.collect{|i| self[i]}}
  end

  def slice(slices)
    result = []
    slices.times do |i|
      start = i * ((size / slices) + 1)
      ending = [(i+1) * ((size / slices) + 1),size].min
      result << self[start...ending] unless start >= ending
    end
    result
  end

  def vector_partial_sum(rhs, from, to)
    result = dup
    (from..to).each{|i| result[i] += rhs[i]}
    result
  end
end

def all_choices(n,k,&p)
    if k == 1
      for i in (0...n) do
	p.call([i])
      end
      return
    end
    for i in ((k-1)...n) do
      all_choices(i,k-1){|t| p.call(t + [i])}
    end
end

puts (0..19).to_a.slice(5).inspect