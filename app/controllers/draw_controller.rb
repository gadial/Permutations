require 'polyominoes'
require 'permutator'
class DrawController < ApplicationController
  def index
    coords = get_coords
    if session[:polyomino] and not params[:clear]
      @polyomino = session[:polyomino]  
    else
      @polyomino = default_polyomino
    end
    @polyomino.change_sqaure_at_screen_coords(coords) if coords
    @polyomino_pic_name = "images/tmp/" + @polyomino.hash.to_s + ".png"
    @polyomino.draw.write("public/" + @polyomino_pic_name)

    @permutation = standard_permutator.permute(@polyomino)
    session[:polyomino] = @polyomino
  end
  private
  def default_polyomino
    p = Polyomino.new
    p << [0,0]
    return p
  end
  def get_coords
    return [$1.to_i, $2.to_i] if params.keys.find{|key| key =~ /(\d+),(\d+)/}
    nil
  end
end
