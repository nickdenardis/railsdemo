class AddingPublicUrLtoSnapshots < ActiveRecord::Migration
  def change
  	add_column :snapshots, :public_url, :string
  end
end
