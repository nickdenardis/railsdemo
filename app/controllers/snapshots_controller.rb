class SnapshotsController < ApplicationController
	before_filter :load_site

  def index
  	@snapshot = Snapshot.new
  	@snapshot.site_id = @site.id
  	
    @snapshot_list = @site.snapshots
  end

  def create
  	# Set the values from the form
    @snapshot = Snapshot.new :site_id => @site

    #render :text => params.inspect

    if @snapshot.save
      redirect_to site_snapshots_path, :flash => {:notice => "Successfully created snapshot."}
    else
      redirect_to :back, :flash => {:error => 'Error creating URL.'}
    end
  end

  private
  	def load_site
  		@site =  Site.find(params[:site_id]) unless params[:site_id].nil?
		end
end
