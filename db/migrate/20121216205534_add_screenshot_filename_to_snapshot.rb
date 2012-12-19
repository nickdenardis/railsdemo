class AddScreenshotFilenameToSnapshot < ActiveRecord::Migration
  def change
  	add_column :snapshots, :filename, :string
  end
end
