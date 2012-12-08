class AddMetaInfoToSitesTable < ActiveRecord::Migration
  def change
  	add_column :sites, :is_ssl, :boolean, :default => 0
  	add_column :sites, :domain, :string
  	add_column :sites, :uri, :string
  end
end
