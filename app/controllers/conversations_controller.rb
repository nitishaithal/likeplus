class ConversationsController < ApplicationController

  layout false
  
  def show
    @conversation_id = params[:id]
  end

end
