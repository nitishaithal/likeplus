class MyPicture 
	include Neo4j::ActiveRel
	property :visible, :type => Boolean
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes


  from_class User
  to_class   Picture
  type 'pictures'

end
