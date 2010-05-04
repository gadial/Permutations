require 'auxiliary'
class Permutation
  attr_reader :vals
  include Comparable
  def initialize(vals = [])
    @vals = vals
  end
  def dup
    Permutation.new(@vals.dup)
  end
  def Permutation.all(n)
    (1..n).to_a.all_permutations.collect{|p| Permutation.new([0]+p)}
  end
  def Permutation.cycle(cyc)
    vals = []
    for i in 1..cyc.max do
      vals[i] = i
    end
    for i in 0...cyc.length do
      vals[cyc[i]] = cyc[(i+1) % cyc.length]
    end
    return Permutation.new(vals)
  end

  def max
    @vals.length - 1
  end
  def cycle_decomposition
    cycles = []
    unused_vals = (1..max).to_a
    while not unused_vals.empty?
      cycle = [unused_vals.min]
      while cycle.first != @vals[cycle.last]
        cycle << @vals[cycle.last]
      end
      unused_vals -= cycle
      cycles << cycle
    end
    cycles
  end
  def <=>(rhs)
    @vals[1..-1] <=> rhs.vals[1..-1]
  end
  def eql?(rhs)
    @vals[1..-1].eql?(rhs.vals[1..-1])
  end
  def hash
    @vals[1..-1].hash
  end
  def to_cycles(show_trivial_cycles = false)
    s = cycle_decomposition.collect do |c|
      result = "(" + c.collect{|x| "#{x}"}.join(" ") + ")"
      result = "" if c.length == 1 and not show_trivial_cycles
      result
    end.join("")
    s = "e" if s == ""
    s
  end
  def to_s
    "(" + @vals[1..-1].join(", ") + ")"
  end

  def[](n)
    return n if @vals[n] == nil
    return @vals[n]
  end

  def *(rhs)
    new_vals = []
    (1..[max,rhs.max].max).each do |n|
      new_vals[n] = self[rhs[n]]
    end
    return Permutation.new(new_vals)
  end
  def subpermutations
    result = []
    for i in 1..max
      temp_vals = @vals.dup
      temp_vals.delete(i)
      temp_vals.collect!{|x| ((x<i)?(x):(x-1))}
      result << Permutation.new(temp_vals)
    end
    result.uniq
  end
  def subpermutations_of_size(k)
    return [] if k>max
    result = [self.dup]
    (max - k).times {result = result.collect{|x| x.subpermutations}.union}
    return result
  end
  def has_subpermutations?(list, size)
    not (subpermutations_of_size(size) & list).empty?
  end
  def has_subpermutation?(p)
    subpermutations_of_size(p.size).include?(p)
  end
  def inspect
    to_s
  end
  def size
    @vals.length - 1
  end
  def draw(width = 7, height = 7)
    k = 50
    n = (size+1) * k
    RVG::dpi = 72
    rvg = RVG.new(width.in, height.in).viewbox(0,0,n,n) do |canvas|
      canvas.background_fill = 'white'
      canvas.g do |body|
          body.styles(:fill=>'white', :stroke=>'black', :stroke_width=>10)
          body.rect(n, n, 0, 0)
      end
      canvas.g do |body|
	  body.styles(:fill=>'red', :stroke=>'black', :stroke_width=>2)
	  @vals.each_index{|i| body.ellipse(k/5, k/5, i*k, @vals[i]*k) unless i==0}
      end

      vertical_lines = (2..size).find_all{|i| @vals[i] < @vals[i-1]}
      horizontal_lines = (2..size).find_all{|i| @vals.index(i) > @vals.index(i-1)}

      canvas.g do |body|
        body.styles(:fill=>'black', :stroke=>'black', :stroke_width=>2)
        vertical_lines.each{|i| body.line(i*k-k/2,0,i*k-k/2,n)}
        horizontal_lines.each{|i| body.line(0,i*k-k/2,n,i*k-k/2)}
      end
    end
    rvg.draw.flip
  end
  def draw_with_text(width = 7.in,height = 7.in)
    im = ImageList.new
    im << draw(width, height)
    im.page.x = 0
    im.page.y = 0
    RVG::dpi = 72
    rvg = RVG.new(width, height).viewbox(0,0,200,300) do |canvas|
      canvas.background_fill = 'white'
      canvas.text(100, 150) do |title|
          title.tspan(inspect).styles(:text_anchor=>'middle', :font_size=>65, :font_family=>'helvetica', :fill=>'black')
      end
    end
    im << rvg.draw
    page = Magick::Rectangle.new
    page.y = im.first.rows
    im.page = page
    im.mosaic
#     rvg.draw
  end
  def is_costas_array
    displacement_vectors = []
    (1..size).each{|i| (1...i).each{|j| displacement_vectors << [i-j,@vals[i]-@vals[j]]}}
    return displacement_vectors.uniq == displacement_vectors
  end
  def to_classical_pattern
    @vals[1..-1].join("-")
  end
end

def generate_all_containing_permutations(n, p_string)
  result = []
  edges_in_adjacent_rows = true if p_string[0..0] == "["   and p_string[-1..-1] == "]"
  p_string = p_string.delete("[]")
  length = p_string.delete("-").length
  return result if length > n
  raise "not a legal string" unless p_string.delete("-").split("").collect{|x| x.to_i}.sort == (1..length).to_a
  vals = (1..n).to_a
  p_string = "-" + p_string + "-"
  vals.all_choices_without_repetitions(length).collect{|x| x.sort}.uniq.each do |c|
    if edges_in_adjacent_rows
      start_num = p_string.delete("-")[0..0].to_i
      end_num = p_string.delete("-")[-1..-1].to_i
      next unless (c[start_num-1]-c[end_num-1]).abs == 1
    end
    remains = (vals - c).collect{|x| x.to_s}
    strings = p_string.replace_by_order(c).multiple_injection(remains,"-").collect{|s| s.delete!("-")}
    result += strings
  end
  result.collect{|t| Permutation.new([0] + t.split("").collect{|x| x.to_i})}
end

def pattern_avoding_permutations(n,patterns)
  result = Permutation.all(n)
  patterns.each{|p| result -= generate_all_containing_permutations(n,p)}
  result
end

def count_avoiding(max,patterns)
  result = (1..max).collect do |n|
    permutations = pattern_avoding_permutations(n, patterns)
    permutations.length
  end
end

def all_permutations(n,k, &p)
  perms = Permutation.all(n)
  all_choices(perms.length,k){|c| p.call(c.collect{|i| perms[i]})}
end

def all_classical_patterns(n,k,&p)
  all_permutations(n,k){|p_set| p.call(p_set.collect{|perm| perm.to_classical_pattern})}
end