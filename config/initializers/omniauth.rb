Rails.application.config.middleware.use OmniAuth::Builder do
 provider :facebook, FACEBOOK_CONFIG['FACEBOOK_APP_ID'], FACEBOOK_CONFIG['FACEBOOK_SECRET'], :scope => 'email,user_birthday,user_photos,user_about_me,user_location,user_hometown,user_relationship_details,user_relationships,user_tagged_places,user_website,user_work_history,user_status,user_education_history,user_friends'
 #,read_friendlists '


end

