require 'polyominoes'
require 'permutations'

class Permutator
  def initialize(name)
    @name = name
  end
  def to_s
    @name
  end
  def inspect
    to_s
  end
  def disallowed_permutations
    Permutation.all(4) - standard_polyominoes[4].collect{|p| permute(p)}.sort
  end
  def disallowed_permutations_count_fails(n = 5)
    disallowed_permutations.collect do |p|
      count = standard_polyominoes[n].collect{|polyomino| permute(polyomino)}.find_all{|per| per.has_subpermutation?(p)}.length
      [p,count]
    end
  end
  def disallowed_polyominoes_image(n = 5)
    dis = disallowed_permutations
    image_from_polyominoes(standard_polyominoes[n].find_all{|polyomino| permute(polyomino).has_subpermutations?(dis,4)},self)
  end
  def allowed_polyominoes_image(n = 5)
    dis = disallowed_permutations
    image_from_polyominoes(standard_polyominoes[n].reject{|polyomino| permute(polyomino).has_subpermutations?(dis,4)},self)
  end
end

class Function
  attr_reader :name
  def initialize(proc, name)
    @proc = proc
    @name = name
  end
  def call(*params)
    @proc.call(*params)
  end
end


class FunctionalPermutator < Permutator
  #gets two functions in x,y: f,g. Compares using the following functions:
  #[f(x_1,y_1),g(x_1,y_1)] <=> [f(x_2,y_2),g(x_2,y_2)]
  #[g(x_1,y_1),-f(x_1,y_1)] <=> [g(x_2,y_2),-f(x_2,y_2)]
  def initialize(f1,g1,f2,g2)
    super("[#{f1.name}, #{g1.name} : #{f2.name}, #{g2.name}]")
    @sort_func_1 = Proc.new{|a,b| [f1.call(a.x,a.y),g1.call(a.x,a.y)] <=> [f1.call(b.x,b.y),g1.call(b.x,b.y)]}
    @sort_func_2 = Proc.new{|a,b| [f2.call(a.x,a.y),g2.call(a.x,a.y)] <=> [f2.call(b.x,b.y),g2.call(b.x,b.y)]}
  end
  def permute(p)
    a_arr = p.squares.sort{|a,b| @sort_func_1.call(a,b)}
    b_arr = p.squares.sort{|a,b| @sort_func_2.call(a,b)}
    vals = [0]
    a_arr.each{|x| vals << (b_arr.index(x) + 1)}
    Permutation.new(vals)
  end
end

def standard_permutator
  f1 = Function.new(Proc.new{|x,y| x},"x")
  f2 = Function.new(Proc.new{|x,y| -x},"-x")
  g1 = Function.new(Proc.new{|x,y| y},"y")
  FunctionalPermutator.new(f1,g1, g1,f2)
end
