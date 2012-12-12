require 'nokogiri'
require 'open-uri'

class SnapshotsController < ApplicationController
	before_filter :load_site

  def index
  	@snapshot = Snapshot.new
  	@snapshot.site_id = @site.id
  	
    @snapshot_list = @site.snapshots
  end

  def create
  	# Set the values from the form
    @snapshot = Snapshot.new :site_id => @site.id

    # Get the document HTML
    doc = Nokogiri::HTML(open(@snapshot.site.url))

    # Set the full HTML
    @snapshot.raw_html = doc.content

    # Set the title of the page (should only be one, but currently getting the last)
    doc.xpath('//title').each do |title|
        @snapshot.title = title.content
    end

    #render :json => @snapshot
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
