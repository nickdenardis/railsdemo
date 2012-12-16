require 'nokogiri'
require 'open-uri'
require 'net/http'

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

    # Take the screenshot
    take_screenshot

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

    def take_screenshot
      Net::HTTP.start('immediatenet.com') do |http|
        @snapshot.filename = @site.domain + '.' + Time.now.to_i.to_s + '.jpg'
        f = open(Rails.root.join('tmp', 'uploads', @snapshot.filename), 'wb+');
        begin
          http.request_get('/t/fs?Size=1024x768&URL=' + @site.domain + '/' + @site.uri) do |resp|
            resp.read_body do |segment|
              f.write(segment)
            end
          end
        ensure
          f.close()
        end
      end
    end
end
