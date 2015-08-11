class BadgesController < ApplicationController
  include ActionController::Live
def create
  badgeType = params[:my_badge][:badgeType]
     @user = User.find(params[:user_id])
    if params[:my_badge][:badgeType].nil?
      @req_badges = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
      @badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").where("myBadge.status = true").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
      return
    end
      @badge = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{params[:user_id]}' })").where("   myBadge.badgeType = '#{badgeType}'  ").pluck(:myBadge)
    if @badge.count > 0 && params[:post_id].nil?
      @req_badges = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
      @badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").where("myBadge.status = true").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
      return
    end
     @badge = Badge.find_by(badgeType: badgeType)
     @myBadge = MyBadge.create(badge_params)
     @give_badge_rel =  GiveBadge.create(from_node: current_user, to_node: @myBadge)
     @badge_detail_rel =  BadgeDetail.create(from_node: @myBadge, to_node: @badge)
     @get_badge_rel =  GetBadge.create(from_node: @user, to_node: @myBadge)
     unless params[:post_id].nil?
       @post = Post.find(params[:post_id])
       @post_badge_rel =  PostBadge.create(from_node: @post, to_node: @myBadge)
     end
     @req_badges = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
     @badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").where("myBadge.status = true").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
     @post_badges = Neo4j::Session.query.match("(post { uuid: '#{@post.uuid}' })-[:postBadges*..]->(myBadge)").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')
    	respond_to do |format|
        format.js {
    	    unless params[:post_id].nil?
                render 'add_tag' 
            end
            }
        format.json { }
    end
end

def destroy
  @badge = MyBadge.find(params[:id])
  @badge.rels(dir: :incoming, type: "giveBadges")[0].destroy
  @badge.rels(dir: :outgoing, type: "badgeDetails")[0].destroy
  @badge.rels(dir: :incoming, type: "getBadges")[0].destroy
  @badge.destroy
  @user = User.find(session['user_id'])
  #@req_badges = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
  #@req_badges = Neo4j::Session.query.match("(any_user)-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
  @badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").where("myBadge.status = true").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')

end

def update
end

def like
  @likebadge = MyBadge.find(params[:id])
  @likebadge.status = true
  @likebadge.save!
  @user = User.find(session['user_id'])
  #@req_badges = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
  #@req_badges = Neo4j::Session.query.match("(any_user)-[:giveBadges]->(myBadge)<-[:getBadges]-(user { uuid: '#{@user.uuid}' })").where("   myBadge.status = false  ").pluck(:myBadge)
  @badges = Neo4j::Session.query.match("(me { uuid: '#{@user.uuid}' })-[:getBadges]->(myBadge)").where("myBadge.status = true").pluck('DISTINCT myBadge.badgeType, count(myBadge.badgeType)')

end

def badge_list
  @user = User.find(session['user_id'])
  #@badges = @user.getBadges.where(badgeType: params[:type], status: true)
  @badges = @user.getBadges.where(badgeType: params[:type])
  render :layout => false
end

  def index
    #text/event-stream content type
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)
    begin
      loop do
        sse.write({ :time => Time.now})
        sleep 1
      end
    rescue IOError
      ensure
        sse.close
      end
    end
  end

private

def badge_params
   params.require(:my_badge).permit(:badgeType, :comment)
end


end
