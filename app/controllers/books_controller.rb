class BooksController < ApplicationController
 before_action :authenticate_user!
 before_action :ensure_correct_user, only: [:edit, :update, :destroy]
  def index
  to = Time.current.at_end_of_day
  from = (to - 6.day).at_beginning_of_day
  @books = Book.includes(:favorites).sort_by { |book| -book.favorites.where(created_at: from...to).count }
  @book = Book.new
  end

def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
   if @book.save
    redirect_to book_path(@book), nothice: "You have created book successfully."
   else
     @books = Book.all
     render 'index'
   end
end


  def show
    @book = Book.find(params[:id])
    @user = @book.user
    @book_comment = BookComment.new
  end


  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render :edit
    end
  end

  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body, :star)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end
