class TagsearchesController < ApplicationController
  def search
    @madel = Book
    @word = params[:content]
    @books = Book.where("category LIKE?","%#{@word}%")
    render "tagsearches/tagsearch"
  end
end
