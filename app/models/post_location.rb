class PostLocation
	include Neo4j::ActiveRel
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes

  from_class Post
  to_class   MyLocation
  type 'post_location'

end
