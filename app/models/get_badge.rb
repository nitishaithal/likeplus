class GetBadge 
	include Neo4j::ActiveRel
	property :like, :type => Boolean
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes

  from_class User
  to_class   MyBadge
  type 'getBadges'

end
