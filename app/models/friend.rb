class Friend 
	include Neo4j::ActiveRel
	property :provider, :type => String
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes

  from_class User
  to_class   User
  type 'friends'

end
