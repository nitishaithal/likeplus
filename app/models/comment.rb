class Comment
  include Neo4j::ActiveNode

  property :content, :type => String, :index => :exact #, constraint: :unique
  property :status, :type => String, :index => :exact #, constraint: :unique
  
   property :created_at  # will automatically be set when model changes
	property :updated_at  # will automatically be set when model changes

  
  has_one :in, :userComment,  model_class: User,  rel_class: UserComment
  has_one :in, :comments,  model_class: Post,  rel_class: PostComment

end
