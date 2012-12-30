require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'fog'
require 'uri'

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

    # Save the initial snapshot to get an ID
    if !@snapshot.save
      redirect_to :back, :flash => {:error => 'Error adding URL.'} and return
    end

    # Parse the assets for the URL
    parse_snapshot_assets

    # Redirect to the snapshot path
    redirect_to site_snapshot_path(@site, @snapshot), :flash => {:notice => 'URL and Assets found!'} and return


  	# # Set the values from the form
   #  @snapshot = Snapshot.new :site_id => @site.id

   #  # Get the document HTML
   #  doc = Nokogiri::HTML(open(@snapshot.site.url))

   #  # Set the full HTML
   #  @snapshot.raw_html = doc.content

   #  # Make sure the current HTML isn't the same as the last
   #  if Snapshot.count() > 1
   #    @last_snapshot = Snapshot.last()

   #    if @last_snapshot.raw_html.eql?(@snapshot.raw_html)
   #      redirect_to :back, :flash => {:error => 'No change, snapshot same as the last.'} and return
   #    end
   #  end

   #  # Set the title of the page (should only be one, but currently getting the last)
   #  doc.xpath('//title').each do |title|
   #      @snapshot.title = title.content
   #  end

   #  # Take the screenshot
   #  if !Rails.env.test?
   #    take_screenshot

   #    # Store the screenshot on Amazon
   #    #@snapshot.public_url = amazon_store

   #    # Remove the local file now (maybe leave 6 on the local server?)
   #    if @snapshot.public_url
   #      remove_local_screenshot
   #    end
   #  end
    
   #  #render :json => @snapshot
   #  if @snapshot.save
   #    redirect_to site_snapshots_path, :flash => {:notice => "Successfully created snapshot."}
   #  else
   #    redirect_to :back, :flash => {:error => 'Error creating URL.'}
   #  end
  end

  def show
    # Find the snapshot in the DB
    @snapshot = Snapshot.find(params[:id])

    # Get all the assets from the DB
    @snapshot_assets = @snapshot.assets.find(:all)

    # Calculate the total size of all assets
    @total_filesize = 0
    @snapshot_assets.each do |file| 
      @total_filesize += file.filesize.to_i
    end
  end

  private
  	def load_site # Need to make this more global
      # Require the user to be logged in
      @current_user ||= User.find(session[:user_id]) if session[:user_id]

      # Make sure the user is logged in
      if !@current_user
        redirect_to root_url, :flash => {:error => 'You must be logged in to see the site list.'}
      end

      # Get the site from the DB
  		@site = Site.find(params[:site_id]) unless params[:site_id].nil?
		end

    def take_screenshot
      # Make the directory unless it exisits
      Dir.mkdir(Rails.root.join('tmp', 'uploads'), 0775) unless File.directory?(Rails.root.join('tmp', 'uploads'))

      # Start the connection and write the local file
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

      # Return the full public URL
      file.public_url
    end

    def parse_snapshot_assets
      # Parse the HTML
      @doc = Nokogiri::HTML.parse(open(@site.url))
      original_filesize = @doc.to_html.size

      # Grab all the images
      @doc.css('img').each do |image|
        if image['src'] != nil
          @new_image_asset = Asset.create :snapshot_id => @snapshot.id, :src_type => 'img', :full_url => create_full_url(@site.url, image['src'])
          if @new_image_asset.local_path != nil
            image['src'] = @new_image_asset.local_path[1..-1]
          end
        end
      end

      # Grab all the css files
      @doc.xpath('//link[@type="text/css"]').each do |css|
        if css['href'] != nil
          @new_css_asset = Asset.create :snapshot_id => @snapshot.id, :src_type => 'css', :full_url => create_full_url(@site.url, css['href'])
          if @new_css_asset.local_path != nil
            css['href'] = @new_css_asset.local_path[1..-1]
          end
        end
      end

      # Grab all the css files alternate
      @doc.xpath('//link[@rel="stylesheet"]').each do |css|
        if css['href'] != nil
          @new_css_asset = Asset.create :snapshot_id => @snapshot.id, :src_type => 'css', :full_url => create_full_url(@site.url, css['href'])
          if @new_css_asset.local_path != nil
            css['href'] = @new_css_asset.local_path[1..-1]
          end
        end
      end

      # Grab all the js files
      @doc.xpath('//script[@type="text/javascript"]').each do |js|
        if js['src'] != nil
          @new_js_asset = Asset.create :snapshot_id => @snapshot.id, :src_type => 'js', :full_url => create_full_url(@site.url, js['src'])
          if @new_css_asset.local_path != nil
            js['src'] = @new_css_asset.local_path[1..-1]
          end
        end
      end

      # Save the newly updated HTML page
      @index_asset = Asset.create :snapshot_id => @snapshot.id, :src_type => 'html',  :full_url => @site.url, :filesize => original_filesize

      #Resave the HTML
      html = @doc.to_html
      f = open(Rails.root.join('tmp', 'uploads', @snapshot.id.to_s, 'index.html').to_s, 'wb+');
      begin
        f.write(html)
      ensure
        f.close()
      end
    end

    def create_full_url(host_uri, file_uri)
      uri = URI(host_uri)

      # Create the full URI
      full_uri = file_uri

      # If it is local to the folder
      if file_uri[0] != '/'
        full_uri = URI.join("#{uri.scheme}://#{uri.host}", uri.path, file_uri).to_s
      end

      # If it is absolute local
      if file_uri[0] == '/'
        full_uri = URI.join("#{uri.scheme}://#{uri.host}", file_uri).to_s
      end

      # If it is relative to the scheme
      if file_uri[0..1] == '//'
        full_uri = uri.scheme + file_uri
      end

      # Ensure the full URL matches a fully qualified URL format
      parsed_full_uri = URI.parse(full_uri)
      
      if parsed_full_uri.kind_of?(URI::HTTP)
        full_uri
      else
        nil
      end
    end
end
