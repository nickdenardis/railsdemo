class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.integer :site_id
      t.string :title
      t.text :raw_html

      t.timestamps
    end
  end
end
