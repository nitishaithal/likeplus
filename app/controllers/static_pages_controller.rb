class StaticPagesController < ApplicationController

  def home
  	@user = current_user
  	unless @user.nil?
      session['user_id'] = @user.uuid
      session['user_gender'] = @user.gender
  		@pictures = @user.pictures.nil? ? []: @user.pictures.where(visible: true)
  		@testimonials = @user.testimonials
      @latitude = nil #'12.9715987'
      @longitude = nil #'77.5945627'
      @interests = @user.userInterests
      @interests_count = @interests.count
      #@req_badges = Neo4j::Session.query.match("(any_user)-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
      #@badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").where("myBadge.status = true").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
      @badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
      @locations = @user.places
  	end
  end

  def help
  end
end
