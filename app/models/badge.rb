class Badge
  include Neo4j::ActiveNode

  property :badgeType, :type => String, :index => :exact #, constraint: :unique
  property :pic, :type => String
  property :about, :type => String

  has_one :in, :badgeDetails,  model_class: MyBadge,  rel_class: BadgeDetail

end
