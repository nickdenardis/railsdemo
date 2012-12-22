require 'bcrypt'

class User < ActiveRecord::Base
	attr_accessible :email, :password, :password_confirmation
  
  attr_accessor :password
  before_save :encrypt_password
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email

  has_many :sites
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticated
    # Require the user to be logged in
    @current_user ||= User.find(session[:user_id]) if session[:user_id]

    if !@current_user
      redirect_to root_url, :flash => {:error => 'You must be logged in to see the site list.'}
    end
  end
end
