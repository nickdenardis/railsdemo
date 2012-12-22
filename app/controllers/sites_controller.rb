require 'uri/http'

class SitesController < ApplicationController
  before_filter :auth_user

  def index
  	@site = Site.new
  	@site_list = @current_user.sites.all
  end

  def create
  	# Set the values from the form
    @site = Site.new params[:site]

    # Associate the site with the logged in user
    @site.user_id = @current_user.id

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
  end

  def show
    @site = Site.find(params[:id])

    # Ensure the site is owned by this user
    if @site.user_id != @current_user.id
      redirect_to :back, :flash => {:error => 'You are not the site owner'}
    end
  end

  def destroy
    @site = Site.find(params[:id])

    # Ensure the site is owned by this user
    if @site.user_id != @current_user.id
      redirect_to :back, :flash => {:error => 'You are not the site owner'}
    end

    if @site.destroy
      redirect_to sites_path, :notice => 'Successfully deleted site.'
    else
      redirect_to site_path(@site), :error => 'Error deleting URL'
    end
  end

  private

  def auth_user
    #Need to make this more global

    # Require the user to be logged in
    @current_user ||= User.find(session[:user_id]) if session[:user_id]

    if !@current_user
      redirect_to root_url, :flash => {:error => 'You must be logged in to see the site list.'}
    end
  end
end
