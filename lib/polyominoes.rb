require 'rvg/rvg'
include Magick

class Array
  def collect_with_index
    result = []
    each_index{|i| result << yield(self[i],i)}
    result
  end
  def each_with_index
    each_index{|i| yield(self[i],i)}
  end
  def contains_full_range
    return true if empty?
    uniq.length == (max - min + 1)
  end
  def all_pairs_with_order
    pairs = []
    each{|x| each{|y| pairs << [x,y]}}
    pairs
  end
  def choose_at_random
    self[rand(length)]
  end
end

class Square
  include Comparable
  attr_reader :coords
  def Square.[](*args)
    return Square.new(args)
  end
  def Square.origin(d)
    Square.new([0]*d)
  end
  def initialize(coords)
    @coords = coords
  end
  def inspect
    @coords.inspect
  end
  def to_s
    inspect
  end
  def dimension
    @coords.size
  end
  def x
    @coords[0]
  end
  def y
    @coords[1]
  end
  def z
    @coords[2] || 0
  end
  def x=(val)
    @coords[0]=val
  end
  def y=(val)
    @coords[1]=val
  end
  def z=(val)
    @coords[2]=val
  end
  def hash
    @coords.hash
  end
  def eql?(rhs)
    @coords == rhs.coords
  end
  def ==(rhs)
    @coords == rhs.coords
  end
  def <=>(rhs)
    @coords <=> rhs.coords
  end
  def [](i)
    @coords[i]
  end
  def neighbor(coord, direction)
    new_coords = @coords.dup
    new_coords[coord] += direction
    Square.new(new_coords)
  end
  def delete_at(i)
    @coords.delete_at(i)
  end
  def neighbors
      @coords.collect_with_index{|s,i| [neighbor(i,1),neighbor(i,-1)]}.flatten
  end
  def legal?
  	Square.origin(self.dimension) <= self
  end
  def legal_neighbors
    neighbors.find_all{|n| n.legal?}
  end
  def dup
    Square.new(@coords.dup)
  end
end

class TriangleSquare < Square
  def TriangleSquare.origin
    TriangleSquare.new([0,0])
  end
  def initialize(args)
    super
  end
  def neighbors
      new_coords = []
      left = @coords.dup
      left[0] -= 1
      right = @coords.dup
      right[0] += 1
      vertical = @coords.dup
      vertical[1] += ((@coords[0]+@coords[1]) % 2 == 0)?(1):(-1)
      return [left, right, vertical].collect{|c| TriangleSquare.new(c)}
  end
end

class Polyomino
  attr_reader :squares
  @@square_size = 40
  def Polyomino.random(n,origin = Square.new([0,0]))
    p = Polyomino.new([origin])
    while p.size < n
      p << (p.squares.collect{|s| s.neighbors}.flatten - p.squares).uniq.choose_at_random
    end
    p
  end
  def hash
    @squares.hash
  end
  def Polyomino.random_path(n,origin = Square.new([0,0]))
    p = Polyomino.new([origin])
    while p.size < n
      p << (p.squares.collect{|s| s.neighbors}.flatten - p.squares).uniq.reject{|s| (s.neighbors & p.squares).size > 1}.choose_at_random
    end
    p
  end
  def dup
    Polyomino.new(@squares.dup)
  end
  def initialize(squares = nil)
    @squares = squares ||= []
  end
  def eql?(other)
    @squares.sort.eql?(other.squares.sort)
  end
  def ==(other)
    @squares.sort == other.squares.sort
  end
  def <<(square)
    case square
    when Square then add_square(square)
    when Array then add_square(Square.new(square))
    end
    self
  end
  def add_square(square)
    @squares << square
    @squares.uniq!
  end
  def remove_square(square)
    @squares.delete(square)
  end
  def neighbors
    @squares.collect{|s| s.neighbors}.flatten.uniq - @squares
  end
  def size
    @squares.size
  end
  def include?(s)
    case s
    when Square then return @squares.include?(s)
    when Array then return @squares.include?(Square.new(s))
    end
    false
  end
  def dimension #determined by the "first" square
    return @squares.first.dimension unless @squares.empty?
    nil
  end
  def is_convex_2d?
    x_vals = @squares.collect{|s| s.x}.uniq
    y_vals = @squares.collect{|s| s.y}.uniq
    x_vals.each do |x|
      return false unless @squares.find_all{|s| s.x == x}.collect{|s| s.y}.contains_full_range
    end
    y_vals.each do |y|
      return false unless @squares.find_all{|s| s.y == y}.collect{|s| s.x}.contains_full_range
    end

    return true
  end
  def cut_2d(dimension_to_remove, i)
    Polyomino.new(@squares.find_all{|s| s[dimension_to_remove] == i}.collect{|s| s.dup}.each{|s| s.delete_at(dimension_to_remove)})
  end
  def is_convex_3d?
#     puts "checking #{self.inspect}"
    (0..2).each {|d| @squares.collect{|s| s[d]}.uniq.each{|i| return false unless cut_2d(d,i).is_convex_2d?}}
    return true
  end
  def draw(dpi = 30)
    k = @@square_size
    max_x = (@squares.collect{|s| s.x}.max || 0) + 1
    min_x = (@squares.collect{|s| s.x}.min || 0) - 1
    max_y = (@squares.collect{|s| s.y}.max || 0) + 1
    min_y = (@squares.collect{|s| s.y}.min || 0) - 1

    size_x = k*(max_x-min_x+1)
    size_y = k*(max_y-min_y+1)
    
    RVG::dpi = dpi
    rvg = RVG.new(size_x,size_y).viewbox(k*(min_x),k*(min_y),size_x,size_y) do |canvas|
      canvas.background_fill = 'white'
      canvas.g do |body|
          body.styles(:fill=>'red', :stroke=>'black', :stroke_width=>3)
          @squares.each{|s| body.rect(k, k, k*s.x, k*s.y)}
      end
    end
    rvg.draw.flip
  end
  def change_sqaure_at_screen_coords(coords)
    k = @@square_size
    max_x = (@squares.collect{|s| s.x}.max || 0) + 1
    min_x = (@squares.collect{|s| s.x}.min || 0) - 1
    max_y = (@squares.collect{|s| s.y}.max || 0) + 1
    min_y = (@squares.collect{|s| s.y}.min || 0) - 1

    size_x = k*(max_x-min_x+1)
    size_y = k*(max_y-min_y+1)

    x = (coords.first / k) + min_x
    y = (((size_y - coords.last) / k) + min_y) #remember we flip

    puts "coords = #{coords.inspect}"
    puts "x,y = #{[x,y].inspect}"
    new_square = Square[x,y]
    if include?(new_square)
      remove_square(new_square)
    else
      add_square(new_square)
    end
  end
end

class LeaperSquare < Square
  def initialize(neighborhood,*args)
    super(*args)
    @neighborhood = neighborhood
  end
  def neighbor(n,t)
    new_coords = @coords.dup
    new_coords[0] += n[0]*t
    new_coords[1] += n[1]*t
    LeaperSquare.new(@neighborhood, new_coords)
  end
  def neighbors
      @neighborhood.collect{|n| [neighbor(n,1), neighbor(n,-1)]}.flatten.uniq
  end
  def LeaperSquare.origin(neigborhood)
    LeaperSquare.new(neigborhood,[0,0])
  end
  def dup
    LeaperSquare.new(@neighborhood,@coords.dup)
  end
end

class RedelmeierAlgorithm
  attr_reader :count, :polyominoes
  def initialize(args)
    @n = args[:n]
    @d = args[:d] || 2
    @count = [0]*(@n+1)
    @p = Polyomino.new
    @stack = []
    @keep_polyominoes = args[:keep_polyominoes]
    @square_type = args[:type]
    @polyominoes = []
    @square_reference_count = {}
    if @square_type == :leaper
      a = args[:leaper_a]
      b = args[:leaper_b]
      @neighborhood = [[a,b],[b,a],[a,-b],[b,-a]]
    else
      @neighborhood = [[1,0],[0,1]]
    end
  end
  def find_and_update_new_neighbors(square)
    n = square.legal_neighbors
    n.each{|s| @square_reference_count[s] ||=0; @square_reference_count[s] +=1}
    n.find_all{|s| @square_reference_count[s] == 1 and not @p.include?(s)}
  end
  def remove_neighbors(square)
    square.legal_neighbors.each{|s| @square_reference_count[s] -= 1; @square_reference_count.delete(s) if @square_reference_count[s] == 0}
  end
  def recurse(untried_set)
    return if @p.size > @n
    @count[@p.size] += 1
    @polyominoes[@p.size] ||= []
    @polyominoes[@p.size] << @p.dup if @keep_polyominoes
    untried_set.each do |new_square|
      untried_set -= [new_square]
      new_untried_set = untried_set.dup + find_and_update_new_neighbors(new_square)
      @p << new_square
      recurse(new_untried_set)
      @p.remove_square(new_square)
      remove_neighbors(new_square)
    end
  end
  def origin
    case @square_type
    when nil, :standard then return Square.origin(@d)
    when :triangles then return TriangleSquare.origin
    when :leaper then return LeaperSquare.origin(@neighborhood)
    end
  end
  def run
    recurse([origin])
    return self
  end
  def results
    @count[1..-1]
  end
end

#p = Polyomino.new
#p << [0,0] << [0,1]
#
#p.draw.display
#a = RedelmeierAlgorithm.new(:n => 6, :type => :leaper, :leaper_a => 1, :leaper_b => 2)
#puts a.run.results.inspect