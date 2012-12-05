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
  end

  describe "PUT /sites" do
  	it "should not allow a blank URL" do
  		visit sites_path
  		fill_in 'Url', :with => ''
  		click_button 'Add Site'

  		current_path.should == sites_path
  		page.should have_content 'Cannot add a blank URL'
  	end
  end
end
