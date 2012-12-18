require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'fog'

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

    # Store the screenshot on Amazon
    @public_url = amazon_store

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

    def amazon_store
      # create a connection
      connection = Fog::Storage.new({
        :provider                 => ENV['PROVIDER'],
        :aws_access_key_id        => ENV['ACCESS_KEY'],
        :aws_secret_access_key    => ENV['ACCESS_SECRET']
      })

      # Get the directory to store the files
      directory = connection.directories.get(ENV['BUCKET_NAME'])

      # list directories
      p connection.directories

      # upload that resume
      file = directory.files.create(
        :key    => "#{@site.domain}/#{@snapshot.filename}",
        :body   => File.open(Rails.root.join('tmp', 'uploads', @snapshot.filename)),
        :public => true
      )

      file.public_url
    end
end
