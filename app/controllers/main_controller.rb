require 'permutations'
class MainController < ApplicationController
  def add_sequence
    Sequence.add(params[:sequence])
    redirect_to :action => :sequences
  end
  def add_permutation_class
    PermutationClass.add(params[:patterns])
    redirect_to :action => :permutations
  end
  def sequences
    @sequences = Sequence.find(:all, :order => "values_string ASC")
  end
  def permutations
    @permutation_classes = PermutationClass.find(:all)
  end
  def sequence
    puts "here!"
    @sequence = Sequence.find_by_values_string(params[:values])
    if @sequence.description == "None"
      @desc = "No description available"
    else
      @desc = advanced_ask_the_oeis(@sequence.values)
    end
  end
  def extend
    n = params[:n].to_i
    k = params[:k].to_i
    if n != 0 and k != 0
      all_classical_patterns(n,k){|patterns| PermutationClass.add(patterns)}
    end
  end
  def draw_permutation
    if params[:permutation] != nil
      
    end
  end
end
