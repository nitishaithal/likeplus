class Post
  include Neo4j::ActiveNode

  property :content, :type => String
  property :post_type, :type => String
  property :status, :type => String
  
  property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes


  has_one :in, :latestpost,  model_class: User,  rel_class: LatestPost
  has_one :both, :nextpost,  model_class: Post ,  rel_class: NextPost
  has_many :out, :comments,  model_class: Comment,  rel_class: PostComment
  has_many :out, :postPictures,  model_class: Picture,  rel_class: PostPicture
  has_one :out, :post_location,  model_class: MyLocation,  rel_class: PostLocation
  has_many :both, :postBadges,  model_class: MyBadge,  rel_class: PostBadge
end
