class MyLocation 
  include Neo4j::ActiveNode

  	property :place_type, :type => String
	  property :details, :type => String
  	property :current_place, :type => Boolean
  	property :address, :type => String, :index => :exact
  	property :name, :type => String, :index => :exact
    property :city, :type => String, :index => :exact
    property :country, :type => String, :index => :exact
  	property :place_id, :type => String, :index => :exact
  	property :id_loc, :type => String, :index => :exact
  	property :latitude, :type => Float, :index => :exact
  	property :longitude, :type => Float, :index => :exact 
 

  has_one :in, :places,  model_class: User,  rel_class: Place
  has_one :in, :post_places,  model_class: User,  rel_class: PostPlace
  has_one :in, :post_location,  model_class: Post,  rel_class: PostLocation
  has_one :out, :location_details,  model_class: Location,  rel_class: LocationMaster
  #has_many :in, :users, origin: :users_place
end
