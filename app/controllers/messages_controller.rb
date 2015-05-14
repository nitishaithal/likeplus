class MessagesController < ApplicationController

  layout false

  def create
    @message = Hash.new
    @conversation_id = params[:conversation_id]
    @message[:body] = params[:body]
    @message[:conversation_id] = params[:conversation_id]
    @message[:user_id] = params[:user_id]
    @message[:created_at] = params[:created_at]
    @message[:updated_at] = params[:updated_at]
  end
 
  private
 
  def message_params
    params.require(:message).permit(:body)
  end

end
