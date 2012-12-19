require 'spec_helper'

describe "Snapshots" do
	before do
  	@site = Site.create :url => 'http://wayne.edu/'
  	#@snapshot = Snapshot.new(:site_id => @site.id)
  end

  describe "GET /sites/:id/snapshots" do
    it "should take a snapshot" do
      visit site_snapshots_path(@site)
      #click_link 'http://wayne.edu/'

      #save_and_open_page

      click_button "New Snapshot"

      current_path.should == site_snapshots_path(@site)
      page.should have_content 'Successfully created snapshot.'
    end

    it "should remove the local screenshot" do
    	visit sites_path
      click_link 'http://wayne.edu/'

      
    end
  end
end
