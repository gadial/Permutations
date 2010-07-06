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
    @polyomino_pic_name = "/images/tmp/" + @polyomino.hash.to_s + ".png"
    @polyomino.draw.write("public" + @polyomino_pic_name)

    @permutation = standard_permutator.permute(@polyomino)
    puts "polyomino = #{@polyomino.inspect}"
    session[:polyomino] = @polyomino
  end
  def polyomino
    puts "polyomino called with params = #{params.inspect}"
    coords = get_coords
    if session[:polyomino] and not params[:clear]
      @polyomino = session[:polyomino]
    else
      @polyomino = default_polyomino
    end
    @polyomino.change_sqaure_at_screen_coords(coords) if coords
    @polyomino_pic_name = "/images/tmp/" + @polyomino.hash.to_s + ".png"
    @polyomino.draw.write("public" + @polyomino_pic_name)

    @permutation = standard_permutator.permute(@polyomino)

    session[:polyomino] = @polyomino
    
    render :partial => "polyomino"
  end

  def polyomino_pic
    puts "polyomino pic called"
    coords = get_coords
    if session[:polyomino] and not params[:clear]
      @polyomino = session[:polyomino]
    else
      @polyomino = default_polyomino
    end
    @polyomino.change_sqaure_at_screen_coords(coords) if coords
    @polyomino_pic_name = "public/images/tmp/" + @polyomino.hash.to_s + ".png"
    @polyomino.draw.write(@polyomino_pic_name)

    @permutation = standard_permutator.permute(@polyomino)

    session[:polyomino] = @polyomino
    send_file(@polyomino_pic_name)
  end
  def permutation
    @polyomino = session[:polyomino]
  end
  private
  def default_polyomino
    puts "default polyomino called"
    p = Polyomino.new
    p << [0,0]
    return p
  end
  def get_coords
    return nil unless params[:x] and params[:y]
    [params[:x].to_i, params[:y].to_i]
  end
end
