class ConversationsController < ApplicationController

  layout false
  
  def show
    @conversation_id = params[:id]
  end
 def start_conversation
    @user=User.find(params[:id])
    @key = " "
    @message ="+"
    if (@user.email  <=> current_user.email) < 0
      @key = @user.email+"_@_"+current_user.email
    else
      @key = current_user.email+"_@_"+@user.email
    end 
      @messages = $redis.get(@key).split(";")
    if @messages.blank?
      @messages = []
    end

    #render partial: "users/chat"

  end

def create
  require "redis"
  redis = Redis.new
  keyis = params[:key]
  newmsg = params[:message]+";"
  @msg = params[:message]
  @user = current_user
  redis.append(keyis, newmsg);

  @messages = $redis.get(keyis).split(";")

end
end
