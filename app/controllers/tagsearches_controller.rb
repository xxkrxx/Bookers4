class TagsearchesController < ApplicationController
  def search
    @madel = Book
    @word = params
    @books = Book.where("category LIKE?","%#{@word}%")
    render "tagesearches/tagsearch"
  end
end
