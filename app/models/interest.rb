class Interest
  include Neo4j::ActiveNode

  property :verified, :type => Boolean, :index => :exact
  property :interestType, :type => String, :index => :exact
  property :interestSubType, :type => String, :index => :exact
  property :rate, :type => String, :index => :exact
  property :about, :type => String

  has_one :in, :userInterests,  model_class: User,  rel_class: MyInterest

end
