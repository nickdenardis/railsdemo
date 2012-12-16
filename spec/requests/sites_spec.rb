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

  	it "add a new site" do
  		visit sites_path
  		fill_in 'Url', :with => 'http://msu.edu/'
  		click_button 'Add Site'

  		current_path.should == sites_path
  		page.should have_content 'http://msu.edu/'
  	end

    it "should show site info" do
      visit sites_path
      click_link 'http://wayne.edu/'

      current_path.should == site_snapshots_path(@site)
      page.should have_content 'http://wayne.edu/'
    end

    it "should take a snapshot" do
      visit sites_path
      click_link 'http://wayne.edu/'

      click_button 'New Snapshot'

      current_path.should == site_snapshots_path(@site)
      page.should have_content 'Successfully created snapshot.'
    end
  end

  describe "PUT /sites" do
  	it "should not allow a blank URL" do
  		visit sites_path
  		fill_in 'Url', :with => ''
  		click_button 'Add Site'

  		current_path.should == sites_path
  		page.should have_content 'Error adding URL.'
  	end

  	it "should not allow a duplicate URL" do
  		visit sites_path
  		fill_in 'Url', :with => 'http://wayne.edu/'
  		click_button 'Add Site'

  		current_path.should == sites_path
  		page.should have_content 'Error adding URL.'
  	end
  end

  describe "DELETE /sites" do
    it "should delete a site" do
      visit sites_path
      click_link 'http://wayne.edu/'

      current_path.should == site_snapshots_path(@site)
      click_link 'Delete'

      current_path.should == sites_path
      page.should have_no_content 'http://wayne.edu/'
    end
  end
end
