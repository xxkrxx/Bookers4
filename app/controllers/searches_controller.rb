class SearchesController < ApplicationController
  # ユーザーの認証を確認するためのフィルター
  before_action :authenticate_user!

  # 検索を実行するアクション
  def search
    # パラメータからモデル、検索対象の内容、検索方法を取得
    @model = params[:model]
    @content = params[:content]
    @method = params[:method]

    # モデルが'user'の場合はユーザーを、それ以外の場合は本を検索
    if @model == 'user'
      @records = User.search_for(@content, @method)
    else
      @records = Book.search_for(@content, @method)
    end
  end
end
