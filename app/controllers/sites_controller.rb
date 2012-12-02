class SitesController < ApplicationController
  def index
  	@site_list = Site.all
  end
end
