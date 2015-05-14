module MessagesHelper

  def self_or_other(message)
    message[:user_id] == current_user.uuid ? "self" : "other"
  end
 
  def message_interlocutor(message)
    message.user_id == message.conversation.sender_id ? message.conversation.sender_id : message.conversation.recipient_id
  end

end
