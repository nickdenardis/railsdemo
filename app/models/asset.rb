class Asset < ActiveRecord::Base
  attr_accessible :filesize, :full_url, :local_path, :snapshot_id, :src_type

  belongs_to :snapshot
end
