class Add_pic 
	include Neo4j::ActiveRel
	property :content, :type => String
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes


  from_class User
  to_class   User
  type 'add_pic'

end
