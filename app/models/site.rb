class Site < ActiveRecord::Base
  attr_accessible :url, :snapshots_attributes

  validates :url, :format => URI::regexp(%w(http https))

  validates_uniqueness_of :url

  has_many :snapshots

  belongs_to :user
end
