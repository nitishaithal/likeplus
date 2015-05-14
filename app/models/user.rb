class User 
  include Neo4j::ActiveNode

  property :name, :type => String, :index => :exact
  property :mood, :type => String
  property :status, :type => String
  property :dob, :type => DateTime, :index => :exact
  property :uid, :type => String, :index => :exact, :unique => true
  property :username, :type => String
  property :email, :type => String, :index => :exact
  property :gender, :type => String, :index => :exact
  property :remember_token, :type => String, :index => :exact
  property :fb_access_token, :type => String, :index => :exact
  property :status, :type => String
  property :about_me, :type => String
  property :default_pic, :type => String
  property :godate_status, :type => Boolean, default: false

  scope :gender_filter, ->(g){ where(gender: g)}

  property :friends_list
  serialize :friends_list

  property :pics
  serialize :pics

  property :visible_pictures
  serialize :visible_pictures

  property :fb_pictures
  serialize :fb_pictures


  #before_save :create_remember_token

  validates :email, :uniqueness => true

  has_many :both, :friends,  model_class: User,  rel_class: Friend
  has_many :both, :friend_girls,  model_class: User,  rel_class: Friend_girl
  has_many :both, :friend_boys,  model_class: User,  rel_class: Friend_boy
  has_many :out, :places,  model_class: MyLocation,  rel_class: Place
  has_many :out, :post_places,  model_class: MyLocation,  rel_class: PostPlace
  has_many :out, :likes, model_class: User,  rel_class: Like
  has_many :out, :crush, model_class: User,  rel_class: Crush
  has_many :out, :godate, model_class: User,  rel_class: GoDate
  #has_many :both, :badges, model_class: User,  rel_class: Badge
  has_many :out, :write_testimonials, model_class: Testimonial,  rel_class: Write_testimonial
  has_many :out, :likes_testimonial, model_class: Testimonial,  rel_class: Like_testimonial
  has_many :in, :testimonials, model_class: Testimonial,  rel_class: My_testimonial
  has_many :out, :pictures,  model_class: Picture,  rel_class: MyPicture
  has_many :out, :userPostPictures,  model_class: Picture,  rel_class: UserPostPicture
  has_many :out, :userInterests,  model_class: Interest,  rel_class: MyInterest
  #has_one :out, :default_pics,  model_class: Picture,  rel_class: Profile
  has_many :out, :visits,  model_class: User,  rel_class: Visit
  has_many :out, :views,  model_class: User,  rel_class: View
  has_many :out, :add_pic,  model_class: User,  rel_class: Add_pic
  has_many :out, :add_status,  model_class: User,  rel_class: Add_status
  has_many :out, :giveBadges,  model_class: MyBadge,  rel_class: GiveBadge
  has_many :out, :getBadges,  model_class: MyBadge,  rel_class: GetBadge
  has_one :out, :latestpost, model_class: Post, rel_class: LatestPost
  has_one :out, :userComment,  model_class: Comment,  rel_class: UserComment

  #has_one :out, :users_place, type: :users_place, model_class: Location
  #has_n(:friends).to(User).relationship(Friend)
  #has_n(:friend_girls).to(User).relationship(Friend_girl)
  #has_n(:friend_boys).to(User).relationship(Friend_boy)

  def self.create_with_omniauth(auth)
    create! do |user|
      user_details = auth['extra']['raw_info']
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.fb_access_token = auth['credentials']['token']
      user.username = auth['info']['nickname']
      user.email = user_details['email']
      user.gender = user_details['gender']
      #user.dob = DateTime.parse(user_details['birthday'])
      user.remember_token = SecureRandom.urlsafe_base64
    end
  end

  def self.paginate(options={})
    page = options[:page] || 1
    per_page = options[:per_page] || 8
   self.skip((per_page-1) * page).limit(per_page)
  end


 private
  def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
  end
  

end
