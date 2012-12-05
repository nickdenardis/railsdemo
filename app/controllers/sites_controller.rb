class SitesController < ApplicationController
  def index
  	@site = Site.new
  	@site_list = Site.all
  end

  def create
  	Site.create params[:site]
  	#render :text => params.inspect
  	redirect_to :back
  end
end
