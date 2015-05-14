class MyBadge
  include Neo4j::ActiveNode

  property :badgeType, :type => String, :index => :exact
  property :status, :type => Boolean, :index => :exact, default: false
  property :comment, :type => String

  has_one :in, :giveBadges,  model_class: User,  rel_class: GiveBadge
  has_one :out, :badgeDetails,  model_class: Badge,  rel_class: BadgeDetail
  has_one :in, :getBadges,  model_class: User,  rel_class: GetBadge
  has_many :both, :postBadges,  model_class: Post,  rel_class: PostBadge

  validates :badgeType, :presence => true

end
