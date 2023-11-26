class MessagesController < ApplicationController
  # 特定のアクション（massage）の前に呼び出されるフィルター
  before_action :check, only: [:message]

  # メッセージ一覧を表示するアクション
  def message
    # 新しいメッセージオブジェクトを作成
    @message = Message.new

    # 送信者または受信者が現在のユーザーであるメッセージを取得し、作成日時でソート
    @messages = Message.where(send_user_id: current_user.id,
                              receive_user_id: params[:id]).or(Message.where(
                                send_user_id: params[:id],
                                receive_user_id: current_user.id
                              )).order(:created_at)
  end

  # メッセージを作成するアクション
  def create
    # 新しいメッセージオブジェクトを作成
    @message = Message.new(message_params)
    @message.send_user_id = current_user.id

    if @message.save!
      # メッセージの保存が成功した場合、対話相手とのメッセージ一覧を取得して作成日時でソート
      @messages = Message.where(send_user_id: current_user.id,
                                receive_user_id: params[:message][:receive_user_id]).or(Message.where(
                                  send_user_id: params[:message][:receive_user_id],
                                  receive_user_id: current_user.id
                                )).order(:created_at)
    else
      # メッセージの保存が失敗した場合、エラー処理を行いメッセージ一覧を再取得して表示
      @message = Message.new
      @messages = Message.where(send_user_id: current_user.id,
                                receive_user_id: params[:message][:receive_user_id]).or(Message.where(
                                  send_user_id: params[:message][:receive_user_id],
                                  receive_user_id: current_user.id
                                )).order(:created_at)
      render :message
    end
  end

  private

  # Strong Parametersを使用して、受け入れ可能なパラメーターをフィルタリング
  def message_params
    params.require(:message).permit(:receive_user_id, :chat)
  end

  # メッセージの送信先や相互フォローの確認を行うためのフィルター
  def check
    # 自分自身とのDMを防ぐ
    if params[:id] == current_user.id
      redirect_back fallback_location: root_path
    else
      # 相互にフォローしているかの確認
      check1 = Relationship.exists?(followed_id: params[:id], follower_id: current_user.id)
      check2 = Relationship.exists?(follower_id: params[:id], followed_id: current_user.id)
      redirect_back fallback_location: root_path if !check1 || !check2
    end
  end
end
