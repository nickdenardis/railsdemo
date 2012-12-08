require 'uri/http'

class SitesController < ApplicationController
  def index
  	@site = Site.new
  	@site_list = Site.all
  end

  def create
  	# Set the values from the form
    @site = Site.new params[:site]

    # Parse the URL
    uri = URI.parse(@site.url)

    # Set the specifics about this URL
    @site.is_ssl = false unless uri.scheme.to_s == 'https'
    @site.domain = uri.host.to_s
    @site.uri = uri.path.to_s
    @site.uri << '?' + uri.query.to_s unless uri.query == nil
    @site.uri << '#' + uri.fragment.to_s unless uri.fragment == nil

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
