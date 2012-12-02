require 'spec_helper'

describe "Sites" do
  before do
  	@site = Site.create :url => 'http://wayne.edu/'
  end

  describe "GET /sites" do
    it "list the sites" do
    	visit sites_path
    	page.should have_content 'http://wayne.edu/'
    end
  end
end
