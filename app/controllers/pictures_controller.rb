class PicturesController < ApplicationController

def create
	@picture = Picture.create!(picture_params)
	@user = current_user
	if !params[:pic_type].nil? && params[:pic_type] == 'post'
	  @post_picture = UserPostPicture.create(from_node: @user, to_node: @picture)
	  
	  respond_to do |format|
        format.js { render 'create_post_pic'  }
        format.json { }
    end
	else  
	#  @my_pictures = MyPicture.create(from_node: @user, to_node: @picture)
  #  @pictures = @user.pictures.nil? ? []: @user.pictures.where(visible: true)
  end
	  @pictures = @user.pictures.nil? ? []: @user.pictures.where(visible: true)
	  
end

def destroy
	@picture = Picture.find(params[:id])
	@picture.rels(dir: :incoming, type: "pictures")[0].destroy
	@picture.destroy
	head :ok
end

def update
	@interest = Interest.find(params[:id])
	@interest.update!(interest_params)
	@interests = current_user.userInterests
	@interests_count = @interests.count
end

def new_upload_form
end

def new_upload_post_form
end

def pics_edit
	@user = current_user
    @pictures = current_user.pictures
end

def set_default_pic
    current_user.default_pic = params[:default_pic]
    current_user.save!
end

  def set_visible_pic
  	@picture = Picture.find_by(pic: params[:visible_pic])
    @picture.visible = params[:status] 
    @picture.save!
	@user = current_user
    @pictures = @user.pictures.nil? ? []: @user.pictures.where(visible: true)
  end

  def import_fb_pictures
    @user = current_user
    @arr = facebook.get_connections("me","albums").map {|p| p["id"] if p["name"] == "Profile Pictures" }.compact
    album_id = @arr[0]
    photo_ids = facebook.get_connections(album_id, "photos").map {|p| p["id"]}
    user_fb_pics = @user.pictures.map {|p| p.fb_id }.compact
        photo_ids.each do |pic|
          unless user_fb_pics.include?(pic)
            up_pic =  Cloudinary::Uploader.upload(@graph.get_object(pic)["source"])["public_id"]
            picture = Picture.create(pic: up_pic, visible: false, fb_id: pic)
            MyPicture.create(from_node: @user, to_node: picture)
          end
        end
    @pictures = current_user.pictures
  end

private

def picture_params
   params.require(:picture).permit(:pic, :visible)
end

end
