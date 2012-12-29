class Snapshot < ActiveRecord::Base
  attr_accessible :raw_html, :site_id, :title, :sites_attributes

  belongs_to :site
  has_many :assets
end
