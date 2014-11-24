class GifsController < ApplicationController


	before_action :authenticate
	#will be the community board where all the gifs are displayed
	#will have links to individaul users and links to tag displays
	#HAS VIEW
	def index
		@gif = Gif.order(created_at: :desc)
	end

	#Will have comments option on this page HAS VIEW
	def show
		@gif = Gif.find(params[:id])
		@tags = Tag.all
	end

	#create a new gif, will also have the tag create in this route.
	#HAS VIEW
	def new
		@gif = Gif.new
		#@tag = Tag.new
	end

	#Post route for the new controller.
	#Will also create a tag and push the tag to the join table

	def create
		cloudconverturl = "https://api.cloudconvert.com/convert?apikey=#{ ENV['CLOUD_CONVERT_KEY'] }&input=download&download=inline&inputformat=mp4&outputformat=gif&file=https%3A%2F%2Fembed.ziggeo.com%2Fv1%2Fapplications%2F#{ ENV['ZIGGEO_APPLICATION_TOKEN'] }%2Fvideos%2F#{params[:videotoken]}%2Fvideo.mp4&converteroptions[video_resolution]=480x320&converteroptions[video_fps]=5"
		conv = HTTParty.get(cloudconverturl)
		sleep(1)
		value = HTTParty.get("https://api.cloudconvert.com/processes?apikey=#{ ENV['CLOUD_CONVERT_KEY'] }")[-1].values[5]
		url = value.gsub("process", "download")
		gif_url = ("https:#{url}?inline")

		@gif = Gif.create({
												image_url: gif_url,
												user_id: session[:current_user_id]
		})
		redirect_to user_path(session[:current_user_id])

		#add tag create
	end

	#delete any specific gif. The gif may only be deleted by its user.
	#I would like this to redirect to the page of the currently logged in user
	#need to work out the redirect path
	def destroy
		@gif = Gif.find(params[:id])
		if @gif.user_id != session[:current_user_id]
			redirect_to user_path(session[:current_user_id])
		else @gif.destroy
			redirect_to user_path(session[:current_user_id])
		end
	end


	#removing individual tag from gif

	def remove_tag
	end



	private

	def tag_params
		params.require(:gif).permit(:name)
	end

end
