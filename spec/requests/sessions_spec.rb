require 'spec_helper'

describe "Sessions" do
  describe "GET /sessions" do
    it "should not let just anyone log in" do
      visit root_url

      click_link 'Log In'

      fill_in 'email', :with => 'user@domain.com'
  		fill_in 'password', :with => 'wrongpassword'
  		click_button 'Log in'

  		current_path.should == sessions_path
  		page.should have_content 'Invalid email or password'
    end

    it "should log in a valid user" do
      @user = User.create :email => 'user@domain.com', :password => 'pass', :password_confirmation => 'pass'

    	visit root_url

    	click_link 'Log In'

    	fill_in 'email', :with => 'user@domain.com'
  		fill_in 'password', :with => 'pass'
  		click_button 'Log in'

  		current_path.should == sites_path
  		page.should have_content 'Logged in!'

    end
  end
end
