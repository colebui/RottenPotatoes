class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #@movies = Movie.all
    @all_ratings = Movie.all_ratings
    redirect = false
    count = 0
    countNonRedirects = 0

    if params[:sort_by]
      @sort_by = params[:sort_by]
      session[:sort_by] = params[:sort_by]
    elsif session[:sort_by]
      @sort_by = session[:sort_by]
      redirect = true
    else
      @sort_by = nil
    end 
    
    if params[:commit] == "Refresh" and params[:ratings].nil?
      @ratings = nil
      session[:ratings] = nil
    elsif params[:ratings]
      @ratings = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif session[:ratings] and not params[:ratings]
      @ratings = session[:ratings]
      redirect = true
    else
      @ratings = nil
    end
    
    if not redirect
      redirect = false
      countNonRedirects = countNonRedirects + 1
    else
      flash.keep
      redirect_to movies_path :sort_by=>@sort_by, :ratings=>@ratings
    end
    
    if @ratings and @sort_by
      @movies = Movie.where(:rating => @ratings.keys).order(params[:sort_by])
    elsif @sort_by and not @ratings
      @movies = Movie.order(params[:sort_by])
    elsif @ratings and not @sort_by
      @movies = Movie.where(:rating => @ratings.keys)
    elsif not @ratings and not @sort_by
      @movie = Movie.all
    end
    if @ratings
      count = count + 1
    else 
      @ratings = Hash.new
    end
    
  end


  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end