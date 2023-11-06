class BookCommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @comment = @book.book_comments.new(book_comment_params)
    @comment.user = current_user
    @comment.save
  end

  def destroy
    @comment =BookComment.find_by(id: params[:id], book_id: params[:book_id])
    @comment.destroy
    @book = Book.find(params[:book_id])
  end

  private

  def book_comment_params
    params.require(:book_comment).permit(:comment)
  end
end

