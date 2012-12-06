class SitesController < ApplicationController
  def index
  	@site = Site.new
  	@site_list = Site.all
  end

  def create
  	@site = Site.new params[:site]
  	if @site.save
  		redirect_to sites_path, :flash => {:notice => "Successfully added #{@site.url}."}
  	else
  		redirect_to :back, :flash => {:error => 'Error adding URL.'}
  	end
  	#render :text => params.inspect
  	#redirect_to :back
  end

  def show
    @site = Site.find(params[:id])
  end

  def destroy
    @site = Site.find(params[:id])

    if @site.destroy
      redirect_to sites_path, :notice => 'Successfully deleted site.'
    else
      redirect_to site_path(@site), :error => 'Error deleting URL'
    end
  end
end
