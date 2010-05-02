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
  def draw_permutation
    if params[:permutation] != nil
      
    end
  end
end
