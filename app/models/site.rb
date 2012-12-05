class Site < ActiveRecord::Base
  attr_accessible :url

  validates :url, :format => URI::regexp(%w(http https))

  validates_uniqueness_of :url
end
