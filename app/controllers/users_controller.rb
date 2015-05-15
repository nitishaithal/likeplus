class UsersController < ApplicationController
autocomplete :location, :address, :full => true

before_filter :signed_in_user, except: :login 

  def login
    oauth = request.env["omniauth.auth"]
    #@user = User.find_by(uid: oauth['uid'])
    @user = User.find_by(email: oauth['info']['email'])
    #session['fb_auth'] = oauth
    
    if  @user.nil?
      @user = User.create_with_omniauth(oauth)
    # @user = User.find_by(email: oauth['extra']['raw_info']['email'])
    #UserMailer.welcome_email(user).deliver
    end
    
    #@user.fb_access_token = oauth['credentials']['token']
    session['fb_access_token'] = oauth['credentials']['token']
    session['fb_error'] = nil
   # @user.save!
    sign_in @user
    
    
    @graph = Koala::Facebook::API.new(session["fb_access_token"])
    
    if @user.default_pic.nil?
      #@user.pictures =  [] if @user.pictures.nil?
      #@user.visible_pictures = [] if @user.visible_pictures.nil?
      @user.default_pic =  Cloudinary::Uploader.upload(@graph.get_picture(@user.uid,:type => "square", height: 400 , width: 400))["public_id"]
      @picture = Picture.create(pic: @user.default_pic, visible: true)
      MyPicture.create(from_node: @user, to_node: @picture)
      #default_pic = @user.default_pic
      #@user.pictures << default_pic
      #@user.visible_pictures << default_pic
      @user.save!
    end
    
       #@pics = @user.pictures.nil? ? [] : @user.pictures
       #@v_pics = @user.visible_pictures.nil? ? [] : @user.visible_pictures

    
       #@user.pictures = nil
       #@user.visible_pictures = nil
       #@user.save!
   # unless profile_pics.empty?
   #   profile_pics.each do |pic_id|
       # picture =  Cloudinary::Uploader.upload(@graph.get_object(pic_id)["source"])["public_id"]
       # @pics << picture
       # @v_pics << picture
    #  end
    # end

    #    @friends = @graph.get_connections("me", "friends")
    #    @user.friends_list = @friends
    #    @user.save!
        
    #    create_fb_friends(@user.uid, @friends)
    #    sign_in @user
    redirect_to root_path
  end

  def friends
    @friends = []
    unless current_user.gender == 'male'
        #@friends = current_user.friend_boys.paginate(:page => params[:page], :per_page => 8)
        @friends = current_user.friend_boys.limit(8)
    else
        @friends = current_user.friend_girls.limit(8)
    end
  end

  def page_friends
        @friends = []
    unless current_user.gender == 'male'
        @friends = current_user.friend_boys.skip((8) * params[:page].to_i-8).limit(8)
    else
        @friends = current_user.friend_girls.skip((8) * params[:page].to_i-8).limit(8)
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    session['user_name'] = @user.name
    session['user_id'] = params[:id]
    session['user_gender'] = @user.gender
    unless @user.uuid == current_user.uuid
      unless  current_user.rels(dir: :outgoing, type: :visits, between: @user).blank?
        rel = current_user.rels(dir: :outgoing, type: :visits, between: @user)
        rel[0].count = rel[0].count + 1
        rel[0].save!
      else
        rel = Visit.new
        rel.from_node = current_user
        rel.to_node = @user
        rel.count = 1
        rel.save!
      end
        current_user.save!
    end
    @my_badges = []

     #@req_badges = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
     #@badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").where("myBadge.status = true").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
     @badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
     @badges_count = @user.getBadges.where(status: true).count

    @pictures = @user.pictures.where(visible: true)
    @testimonials = @user.testimonials

    unless @user == current_user
      t = []
      @testimonials.each do |testimonial|
        if testimonial.liked
         t << testimonial
         next
        end
        if testimonial.write_testimonials[0] == current_user
         t << testimonial
        end
      end
      @testimonials = t
    end
    unless @user.uuid == current_user.uuid
      @like = current_user.rels(dir: :outgoing, type: :likes, between: @user).blank? ? true : false
    end
    unless @user.uuid == current_user.uuid
      place_ids = current_user.places.map { |p| p.place_id }
      @locations = @user.places.where(place_id: place_ids)
    else
      @locations = @user.places
    end
    @likes_count = @user.rels(dir: :incoming, type: "likes").count

    @interests = @user.userInterests
    @interests_count = @interests.count

    # ip_loc = Geocoder.search(remote_ip)[0]

     # @address = ip_loc.address
     # @latitude = ip_loc.latitude
     # @longitude = ip_loc.longitude

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def autocomplete_location_address
    #gc = Geocoder.search(params[:address])
    @client = GooglePlaces::Client.new('AIzaSyAQ-rZcE4h_upePl7jGYTmt1AKypz3qXPk')
    gc = @client.spots_by_query(params[:address])
    result = gc.collect do |t|
      {value: t.name + ' | ' + t.formatted_address }
    end
    respond_to do |format|
      format.json {render json: result}
    end
  end

  def search_criteria
  @friends = []
    location_ids = params[:location_ids]#.map(&:to_i)
    session['gender_search'] = params[:gender]
    session['location_ids'] = location_ids
    @friends = User.as(:u).places(:l).where(place_id: location_ids).where('u.gender = "' + params[:gender] + '"').limit(2).pluck('DISTINCT u')
    #query = Neo4j::Session.query.match(u: :User, l: :Location)
    #query = query.where('u.id' => current_user.neo_id)  
    #query = query.where('l.neo_id' => location_ids)  
    #@friends = query.where('l.id' => location_ids).pluck('DISTINCT u')
    #@friends = @friends - Array(current_user)
  end

  def page_search_criteria
     @friends = []
    location_ids = session['location_ids']
    gender = session['gender_search']
    @friends = User.as(:u).places(:l).where(place_id: location_ids).where('u.gender = "' + gender + '"').skip((2) * params[:page].to_i-2).limit(2).pluck('DISTINCT u')
   # @friends = @friends - Array(current_user)
  end

  def likes
    @user = User.find(params[:id])
    unless  current_user.rels(dir: :outgoing,type: :likes, between: @user).blank?
      rel = current_user.rels(dir: :outgoing,type: :likes, between: @user)
      rel[0].destroy
     # current_user.save!
    else
      current_user.likes << @user
    #  current_user.save!
    end
    @likes_count = @user.rels(dir: :incoming, type: "likes").count
    #, :content_type => 'text/html'
  end

  def like_list
    @friends = []
    @friends = current_user.likes.limit(2)
    respond_to do |format|
      format.html
      format.json { render json: @friends }
    end
  end

  def page_like_list
    @friends = []
    @friends = current_user.likes.skip((2) * params[:page].to_i-2).limit(2)
  end


  def update_status
    @user = current_user
    @user.status = params[:value]
    @user.save!
 
      rel = Add_status.create(from_node: @user, to_node: @user)
      rel.content = params[:value]
      rel.save!

     respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def update_about_me
    current_user.about_me = params[:value]
    current_user.save!

     respond_to do |format|
      format.html
      format.json { render json: current_user }
    end
  end

  def add_testimonial
      @user = User.find(params[:id])
      testimonial = Testimonial.new
      testimonial.say = params[:testimonial]
      testimonial.save!

      rel1 = Write_testimonial.create(from_node: current_user, to_node: testimonial)
      rel1.save!

      rel2 = My_testimonial.create(from_node: testimonial, to_node: @user)
      rel2.save!

      @testimonials = @user.testimonials

      unless @user == current_user
        t = []
        @testimonials.each do |testimonial|
          if testimonial.liked
           t << testimonial
           next
          end
          if testimonial.write_testimonials[0] == current_user
           t << testimonial
          end
        end
        @testimonials = t
      end
  end

  def add_picture
    @user = User.find(params[:id])
    @pictures = []
    @pictures << params[:pic]
    @pics = @user.pictures
    @v_pics = @user.visible_pictures
    
    if @pics.nil?
      @user.pictures = @pictures
    else
       @user.pictures = nil
        @user.save!
        @pics << @pictures[0]
       @user.pictures =  @pics
    end
    if @v_pics.nil?
      @user.visible_pictures = params[:pic]
    else
      @user.visible_pictures = nil
      @user.save!
      @v_pics << params[:pic]
      @user.visible_pictures = @v_pics
    end
    @user.save!

    rel = Add_pic.create(from_node: @user, to_node: @user)
    rel.content = params[:pic]
    rel.save!

    head :ok

  end

  def pics_edit
    @user = User.find(params[:id])
    @pictures = @user.pictures
  end

  def set_default_pic
    @user = User.find(params[:id])
    @user.default_pic = params[:default_pic]
    @user.save!

  end

  def set_visible_pic
    @user = User.find(params[:id])
     @v_pics = @user.visible_pictures
     @user.visible_pictures = nil
     @user.save!
    if params[:status] == 'true'
      @v_pics << params[:visible_pic]
      @user.visible_pictures = @v_pics
    else
      @v_pics.delete(params[:visible_pic])
      @user.visible_pictures = @v_pics
    end
    @user.save!

    head :ok
  end

  def likes_testimonial
    @user = User.find(params[:id])
    @testimonial = Testimonial.find(params[:t_id])
    unless  current_user.rels(type: :likes_testimonial, between: @testimonial).blank?
      rel = current_user.rels(type: :likes_testimonial, between: @testimonial)
      rel[0].destroy
      current_user.save!
      @testimonial.liked = false
      @testimonial.save!
    else
      @testimonial.liked = true
      @testimonial.save!
      current_user.likes_testimonial << @testimonial
      current_user.save!
    end
    @testimonials = @user.testimonials
    
  end

  def delete_testimonial
    @user = User.find(params[:id])
    @testimonial = Testimonial.find(params[:t_id])
    rel = current_user.rels(type: :likes_testimonial, between: @testimonial)
    if rel.nil?
      rel[0].destroy
    end
    @testimonial.destroy

      @testimonials = @user.testimonials
      unless @user == current_user
        t = []
        @testimonials.each do |testimonial|
          if testimonial.liked
           t << testimonial
           next
          end
          if testimonial.write_testimonials[0] == current_user
           t << testimonial
          end
        end
        @testimonials = t
      end
  end

  def timeline
    @results = Neo4j::Session.query.match("(me { uuid: '#{params[:id]}' })-[:likes]->(friend),(friend)-[rel]-(node)").where("  NOT  rel._classname = 'Visit'  AND NOT rel._classname = 'My_testimonial' ").order("rel.updated_at DESC").limit(80).pluck(:friend, :rel, :node)
  end

  def timeline_page
    @results = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:likes]->(friend),(friend)<-[rel]-(node)").where(" NOT  rel._classname = 'Visit'  AND NOT rel._classname = 'My_testimonial' ").order("rel.updated_at DESC").skip((8) * params[:page].to_i-8).limit(8).pluck(:friend, :rel, :node)
  end

  def new_people_around
    @friends = []
     place_ids = current_user.places.map { |p| p.place_id }
    
    unless current_user.gender == 'male'
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(" NOT  (me)-[:views]->(n) ").where(l: {place_id: place_ids}).where( 'n.gender <> "female"').limit(3).pluck(:n)
      if @users.count == 0
          @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l), (me)-[v:views]->(n)").where(l: {place_id: place_ids}).where( 'n.gender <> "female"').order('n.count desc').limit(3).pluck(:n)
      end
    else
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(" NOT  (me)-[:views]->(n) ").where(l: {place_id: place_ids}).where( 'n.gender <> "male"').limit(3).pluck(:n)
      if @users.count == 0
          @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l), (me)-[v:views]->(n)").where(l: {place_id: place_ids}).where( 'n.gender <> "male"').order('n.count desc').limit(3).pluck(:n)
      end
    end
    @friends = @users
  end

  def page_new_people_around
    @friends = []

    if params[:viewed].blank?
      return
    end
    viewed_users = []
    viewed_users = User.all.where(uuid: params[:viewed].split(","))

    viewed_users.each do |user|
      rel = current_user.rels(type: :views, between: user)
      unless rel.blank? 
        rel[0].count += 1
        rel[0].save
      else
        View.create!(from_node: current_user, to_node: user)
      end
    end

    place_ids = current_user.places.map { |p| p.place_id }
    
    unless current_user.gender == 'male'
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(" NOT  (me)-[:View]->(n) ").where(l: {place_id: place_ids}).where( 'n.gender <> "female"').skip((3) * params[:page].to_i-3).limit(3).pluck(:n)
      if @users.count == 0
          @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l), (me)-[v:views]->(n)").where(l: {place_id: place_ids}).where( 'n.gender <> "female"').order('n.count desc').skip((3) * params[:page].to_i-3).limit(3).pluck(:n)
      end
    else
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(" NOT  (me)-[:View]->(n) ").where(l: {place_id: place_ids}).where( 'n.gender <> "male"').skip((3) * params[:page].to_i-3).limit(3).pluck(:n)
      if @users.count == 0
          @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l), (me)-[v:views]->(n)").where(l: {place_id: place_ids}).where( 'n.gender <> "male"').order('n.count desc').skip((3) * params[:page].to_i-3).limit(3).pluck(:n)
      end
    end
    @friends = @users
  end

  def crush
    @user = User.find(params[:id])
    if params[:crush] == 'yes'
      if current_user.rels(dir: :outgoing, type: :crush, between: @user).blank? ? true : false
      Crush.create!(from_node: current_user, to_node: @user)
      end
    else
      current_user.rels(dir: :outgoing, type: :crush, between: @user)[0].destroy
    end
  end

  def crush_list
    @friends = current_user.crush
  end

  def date_list
    place_ids = current_user.places.map { |p| p.place_id }
    
    unless current_user.gender == 'male'
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(n: {godate_status: true}).where(l: {place_id: place_ids}).where( 'n.gender <> "female"').limit(3).pluck(:n)
    else
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(n: {godate_status: true}).where(l: {place_id: place_ids}).where( 'n.gender <> "male"').limit(3).pluck(:n)
    end
    @friends = @users
  end

  def page_date_list
    place_ids = current_user.places.map { |p| p.place_id }
    
    unless current_user.gender == 'male'
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(n: {godate_status: true}).where(l: {place_id: place_ids}).where( 'n.gender <> "female"').skip((3) * params[:page].to_i-3).limit(3).pluck(:n)
    else
      @users = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' }), (n:User), (n)-[:places]->(l)").where(n: {godate_status: true}).where(l: {place_id: place_ids}).where( 'n.gender <> "male"').skip((3) * params[:page].to_i-3).limit(3).pluck(:n)
    end
    @friends = @users
  end


  def set_godate
     @user = User.find(params[:id])
     if params[:godate] == 'yes'
        @user.godate_status = true
        @user.save!
      else
         @user.godate_status = false
        @user.save!
      end
  end

  def godate
    @user = User.find(params[:id])
    if params[:godate] == 'yes'
      if current_user.rels(dir: :outgoing, type: :godate, between: @user).blank?
        GoDate.create!(from_node: current_user, to_node: @user)
      end
    else
      current_user.rels(dir: :outgoing, type: :godate, between: @user)[0].destroy
    end
  end

end
