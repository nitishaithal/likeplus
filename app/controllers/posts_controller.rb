class PostsController < ApplicationController
	
def index
	@results = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:likes*0..]->(friend),(friend)-[:latestpost]->(post)-[:nextpost*0..]->(second_old_post)").where(" NOT ( second_old_post.status = 'delete') or (second_old_post.status is null)").order("second_old_post.updated_at DESC").limit(3).pluck('distinct second_old_post', :friend)
	@user = current_user
end

def next_page
	@results = Neo4j::Session.query.match("(me { uuid: '#{current_user.uuid}' })-[:likes*0..]->(friend),(friend)-[:latestpost]->(post)-[:nextpost*0..]->(second_old_post)").where(" NOT ( second_old_post.status = 'delete') or (second_old_post.status is null)").order("second_old_post.updated_at DESC").skip((3) * params[:page].to_i-3).limit(3).pluck('distinct second_old_post', :friend)
	@user = current_user
end

def create
	@user = current_user
		Neo4j::Transaction.run do
			@post = Post.create!(post_params)
			if !params[:post_type].nil? && params[:post_type] == 'pic'
				@post.post_type = params[:post_type]
				@post.save!
				@picture = Picture.find(params[:post_type_id])
	  			@post_picture = PostPicture.create(from_node: @post, to_node: @picture)
	  		end
	  		if !params[:post_type].nil? && params[:post_type] == 'location'
				@post.post_type = params[:post_type]
				@post.save!
				@picture = MyLocation.find(params[:post_type_id])
	  			@post_location = PostLocation.create(from_node: @post, to_node: @picture)
	  		end
		  	rel = @user.rels(dir: :outgoing, type: "latestpost")
		      unless rel.blank? 
		      	@second_old_post = @user.latestpost
		      	@user.rels(dir: :outgoing, type: "latestpost")[0].destroy
		      	LatestPost.create!(from_node: @user, to_node: @post)
		      	NextPost.create!(from_node: @post, to_node: @second_old_post)
		      	 
		      	#Neo4j::Session.query.match(me: :User).where(me: { uuid: '#{current_user.uuid}' }).optional_match("me-[r:LatestPost]->secondlatestpost").delete(:r).create("(me)-[:LatestPost]->(latest_post { content: 'Status' })").with("latest_post, secondlatestpost").create("latest_post-[:NextPost]->secondlatestpost").pluck(:latest_post)
		      else
		      	LatestPost.create!(from_node: @user, to_node: @post)
		
		      end
		end

	respond_to do |format|
        format.html { redirect_to action: "index" }
        format.json { }
    end
end

def destroy
	@post = Post.find(params[:id])
	@post.status = 'delete'
	@post.save!
end

def update
	@interest = Interest.find(params[:id])
	@interest.update!(interest_params)
	@interests = current_user.userInterests
	@interests_count = @interests.count
end

def badges
	@post = Post.find(params[:id])
	@badgeType = params[:badgeType]
	@badges = @post.postBadges.where(badgeType: params[:badgeType])
end

private

def post_params
   params.require(:post).permit(:content)
end

end
