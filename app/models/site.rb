class Site < ActiveRecord::Base
  attr_accessible :url

  validates :url, :format => URI::regexp(%w(http https))
end
