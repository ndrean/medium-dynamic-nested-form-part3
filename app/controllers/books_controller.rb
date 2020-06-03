class BooksController < ApplicationController
  #### version authors/:id/books/new via a link
  def new
    @author = Author.find(params[:author_id])
    @book = Book.new
    @book.author = @author
  end

  # in the form, we select an author
  # or we prepopulate an author_id, rendered with 'collection[@author]'
  def create
    @author = Author.find(params[:author_id])
    book = Book.new(books_params)
    if book.save
      redirect_to author_books_path(@author)
    else
      render :new
    end
  end
  #####
  def index
    author = Author.find(params[:author_id])
    books = author.books
    render json: books.to_json(only: :title)
  end

  ##### version BOOK & AUTHOR
  def new_book_and_author
    @book = Book.new
    @book.build_author
    # accepts_nesed_attributes_for :author, in Book model
  end

  def create_book_and_author
    # since we find or create an author, no error rendering
    author = Author.find_or_create_by(name: direct_books_params[:author_attributes][:name])
    book = Book.new(title: direct_books_params[:title])
    book.author = author
    
    book.save
    redirect_to authors_path
  end
  ####

  #### version direct /books/new with picking author from collection
  def book_new
    @book = Book.new
  end

  # the form is prepopulated with the author via a link and author_id is passed
  # via the navigation
  def book_create
    book = Book.new(direct_books_params)
    name = direct_books_params[:new_author]
    if !name.blank?
      book.create_author(name: name)
    else
      book.author = Author.find(direct_books_params[:author_id])
    end
    book.save
    redirect_to authors_path
  end
  ####


  private
  def books_params
    params.require(:book).permit(:title, :author_id)
  end

  def direct_books_params
    params.require(:book).permit(:title, :author_id, :new_author, author_attributes: [:name, :id])
  end
end