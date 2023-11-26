class BooksController < ApplicationController
  # ユーザーの認証を確認するためのフィルター
  before_action :authenticate_user!
  # 特定のユーザーに関するアクション（edit、update、destroy）の前に呼び出されるフィルター
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  # 本の一覧を表示するアクション
  def index
    # 期間内のお気に入りの数で本をソートする
    to = Time.current.at_end_of_day
    from = (to - 6.day).at_beginning_of_day
    @books = Book.includes(:favorites).sort_by { |book| -book.favorites.where(created_at: from...to).count }

    # パラメータに応じて本の一覧をフィルタリング
    if params[:latest]
      @books = Book.latest
    elsif params[:old]
      @books = Book.old
    elsif params[:star_count]
      @books = Book.star_count
    else
      @books = Book.old
    end

    # 新しい本を作成するためのBookオブジェクト
    @book = Book.new
  end

  # 本を作成するアクション
  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id

    if @book.save
      redirect_to book_path(@book), notice: "You have created the book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end

  # 特定の本を表示するアクション
  def show
    @book = Book.find(params[:id])

    # ユーザーが特定の本をまだ見ていない場合、ViewCountを作成する
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book.id)
      current_user.view_counts.create(book_id: @book.id)
    end

    @user = @book.user
    @book_comment = BookComment.new
  end

  # 本を編集するためのアクション
  def edit
    @book = Book.find(params[:id])
  end

  # 本を更新するアクション
  def update
    @book = Book.find(params[:id])

    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated the book successfully."
    else
      render :edit
    end
  end

  # 本を削除するアクション
  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path
  end

  private

  # Strong Parametersを使用して、受け入れ可能なパラメーターをフィルタリング
  def book_params
    params.require(:book).permit(:title, :body, :star, :category)
  end

  # ユーザーが正しい本の所有者であるか確認するためのフィルター
  def ensure_correct_user
    @book = Book.find(params[:id])

    unless @book.user == current_user
      redirect_to books_path
    end
  end
end

