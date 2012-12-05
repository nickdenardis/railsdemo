class SitesController < ApplicationController
  def index
  	@site = Site.new
  	@site_list = Site.all
  end

  def create
  	@site = Site.new params[:site]
  	if @site.save
  		redirect_to sites_path, :flash => {:notice => "Successfully added #{@site.url}"}
  	else
  		redirect_to :back, :flash => {:error => 'Not a valid URL.'}
  	end
  	#render :text => params.inspect
  	#redirect_to :back
  end
end
