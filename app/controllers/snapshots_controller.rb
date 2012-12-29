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

    # Make sure the current HTML isn't the same as the last
    if Snapshot.count() > 1
      @last_snapshot = Snapshot.last()

      if @last_snapshot.raw_html.eql?(@snapshot.raw_html)
        redirect_to :back, :flash => {:error => 'No change, snapshot same as the last.'} and return
      end
    end

    # Set the title of the page (should only be one, but currently getting the last)
    doc.xpath('//title').each do |title|
        @snapshot.title = title.content
    end

    # Take the screenshot
    if !Rails.env.test?
      take_screenshot

      # Store the screenshot on Amazon
      #@snapshot.public_url = amazon_store

      # Remove the local file now (maybe leave 6 on the local server?)
      if @snapshot.public_url
        remove_local_screenshot
      end
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
      #Need to make this more global
      
      # Require the user to be logged in
      @current_user ||= User.find(session[:user_id]) if session[:user_id]

      if !@current_user
        redirect_to root_url, :flash => {:error => 'You must be logged in to see the site list.'}
      end

  		@site =  Site.find(params[:site_id]) unless params[:site_id].nil?
		end

    def take_screenshot
      # Make the directory unless it exisits
      Dir.mkdir(Rails.root.join('tmp', 'uploads'), 0775) unless File.directory?(Rails.root.join('tmp', 'uploads'))

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

    def remove_local_screenshot
      if File.exists?(Rails.root.join('tmp', 'uploads', @snapshot.filename))
        File.delete(Rails.root.join('tmp', 'uploads', @snapshot.filename))
      end
    end

    def amazon_store
      # If testing or development
      Fog.mock! unless Rails.env.production?

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
