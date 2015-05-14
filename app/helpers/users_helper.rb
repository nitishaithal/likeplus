module UsersHelper

  def create_fb_friends(uid, friends)
        friends.each do |friend|
         # FbWorker.perform_async(uid, friend['id'], friend['name'])
        end
  end

end
