class AuthorsController < ApplicationController
  def index
    render json: Author.all.order('created_at DESC').includes(:books).to_json(only: [:name], include: [books: {only: :title}])     
  end

  def new
    @author = Author.new
    @author.books.build
  end

  def create
    @author = Author.new(author_params)
    if @author.save
      redirect_to authors_path
    else
      render :new
    end
    # Note : we use @author to render in view in case of error
  end


  def author_params
    params.require(:author).permit(:name, books_attributes:[:title])
  end
end