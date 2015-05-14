class CommentsController < ApplicationController
	
def index

end

def create
	@user = current_user
	@post = Post.find(params[:post_id])
	@comment = Comment.create!(comment_params)
	@rel1 =  UserComment.create!(from_node: @user, to_node: @comment)
	@rel2 =  PostComment.create!(from_node: @post, to_node: @comment)
	@results = Neo4j::Session.query.match("(post { uuid: '#{@post.uuid}' })-[:postComment*..]->(comment),(comment)<-[:userComment]-(user)").where(" NOT ( comment.status = 'delete') or (comment.status is null)").order("comment.created_at DESC").pluck(:comment, :user)
	@pUser = User.find(params[:pUser_id])
	respond_to do |format|
        format.js {  }
        format.json { }
    end
end

def destroy
	@post = Post.find(params[:post_id])
	@comment = Comment.find(params[:id])
	@comment.status = 'delete'
	@comment.save!
	@results = Neo4j::Session.query.match("(post { uuid: '#{@post.uuid}' })-[:postComment*..]->(comment),(comment)<-[:userComment]-(user)").where(" NOT ( comment.status = 'delete') or (comment.status is null)").order("comment.created_at DESC").pluck(:comment, :user)

end

def update
	@comment = Comment.find(params[:id])
	@comment.update!(comment_params)
end

def more
	@post = Post.find(params[:id])
	@results = Neo4j::Session.query.match("(post { uuid: '#{@post.uuid}' })-[:postComment*..]->(comment),(comment)<-[:userComment]-(user)").where(" NOT ( comment.status = 'delete') or (comment.status is null)").order("comment.created_at DESC").pluck(:comment, :user)
	@pUser = User.find(params[:pUser_id])
end

private

def comment_params
   params.require(:comment).permit(:content)
end

end
