require 'spec_helper'

describe "Sites" do
  before do
    # Create the new user
    @user = User.create :email => 'user@domain.com', :password => 'pass', :password_confirmation => 'pass'

    # Log that user in
    #post "/sessions", {:email => "user@domain.com", :password => "pass"}
    #post sessions_path, {:email => "user@domain.com", :password => "pass"}

    #@session_user = User.authenticate('user@domain.com', 'pass')
    #session[:user_id] = @user.id

    visit login_path
    fill_in 'email', :with => 'user@domain.com'
    fill_in 'password', :with => 'pass'
    click_button 'Log in'

    #save_and_open_page

  	@site = Site.create :url => 'http://wayne.edu/'
  end

  describe "GET /sites" do
    it "list the sites" do
    	visit sites_path
      
      #save_and_open_page

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
