require 'uri'
require 'net/http'
require 'nokogiri'

class Asset < ActiveRecord::Base
  attr_accessible :filesize, :full_url, :local_path, :snapshot_id, :src_type

  belongs_to :snapshot

  after_create :download_asset

  def download_asset
    # Create the base directory
    file_dir = Rails.root.join('tmp', 'uploads', snapshot_id.to_s).to_s

    # Do a GET request
    request_get(self.full_url, file_dir)
  end

  def request_get(url, local_path, count = 3)
    return nil unless url != nil

    # Parse the URL
    parsed_uri = URI.parse(url)

    # Make sure the URL is http/https
    if !parsed_uri.kind_of?(URI::HTTP)
      return nil
    end

    # Start the HTTP request
    http = Net::HTTP.new(parsed_uri.host, parsed_uri.port)

    # Start the download
    # Net::HTTP.start(parsed_uri.host) do |http| 
    http.request_get(parsed_uri.path) do |http|
      # Determine what to do based on the response
      case http
        # 3xx
        when Net::HTTPRedirection
          url = http["location"]
          return request_get(url, local_path, count - 1)

        #200
        when Net::HTTPOK
          # Determine the directory and filename
          if self.src_type == 'html'
            filename = 'index.html'
            file_dir = Rails.root.join('tmp', 'uploads', snapshot_id.to_s).to_s
          else
            filename = File.basename(parsed_uri.path)
            file_dir = Rails.root.join('tmp', 'uploads', snapshot_id.to_s).to_s + File.dirname(parsed_uri.path).to_s
          end

          # Make the directory locally
          folder_dir = file_dir.to_s.split('/')
          build_dir = ''

          folder_dir.each { |folder|
              build_dir << "#{folder}/"
              Dir.mkdir(build_dir, 0775) unless File.directory?(build_dir)
          }

          # Create the file locally
          f = open(build_dir + filename, 'wb+');
          begin
            filesize = 0;
            http.read_body do |segment|
              f.write(segment)
              filesize += segment.size
            end

            # If not the original HTML file, save the new size
            if self.filesize == nil
              self.filesize = filesize
            end

            # Save the relative path
            self.local_path = File.join(File.dirname(parsed_uri.path), filename)

            self.save
          ensure
            f.close()
          end
        end
    end
  end
end
