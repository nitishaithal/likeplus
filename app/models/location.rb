class Location 
  include Neo4j::ActiveNode

  property :address, :type => String, :index => :exact
  property :name, :type => String, :index => :exact
  property :place_id, :type => String, :index => :exact
  property :city, :type => String, :index => :exact
  property :country, :type => String, :index => :exact
  property :id_loc, :type => String, :index => :exact
  property :latitude, :type => Float, :index => :exact
  property :longitude, :type => Float, :index => :exact 
 

  has_many :in, :location_details,  model_class: MyLocation,  rel_class: LocationMaster
  #has_many :in, :users, origin: :users_place
end
