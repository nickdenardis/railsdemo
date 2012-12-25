require 'spec_helper'

describe "Users" do
  describe "GET /users" do
    it "should create a new user account" do
    	visit root_path

    	click_link 'Signup'

  		fill_in 'user[email]', :with => 'user@domain.com'
  		fill_in 'user[password]', :with => 'pass'
  		fill_in 'user[password_confirmation]', :with => 'pass'
  		click_button 'Sign Up'

  		current_path.should == root_path
  		page.should have_content 'Signed up!'
  	end

    it "should not allow a duplicate email address" do
      @user = User.create :email => 'user@domain.com', :password => 'pass', :password_confirmation => 'pass'

      visit root_path

      click_link 'Signup'

      fill_in 'user[email]', :with => 'user@domain.com'
      fill_in 'user[password]', :with => 'pass'
      fill_in 'user[password_confirmation]', :with => 'pass'
      click_button 'Sign Up'

      current_path.should == users_path
      page.should have_content 'Email has already been taken'
    end
  end
end
