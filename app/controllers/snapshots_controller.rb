class SnapshotsController < ApplicationController
	before_filter :load_site

  def index
  	@snapshot = Snapshot.new
  	#@snapshot.site_id = @site.id
  	@snapshot_list = @site.snapshots
  end

  private
  	def load_site
  		@site =  Site.find(params[:site_id]) unless params[:site_id].nil?
		end
end
