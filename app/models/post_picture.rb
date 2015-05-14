class PostPicture 
	include Neo4j::ActiveRel
	property :visible, :type => Boolean
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes


  from_class Post
  to_class   Picture
  type 'postPictures'

end
