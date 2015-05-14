class BadgeDetail 
	include Neo4j::ActiveRel
	property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes

  from_class MyBadge
  to_class   Badge
  type 'badgeDetails'

end
