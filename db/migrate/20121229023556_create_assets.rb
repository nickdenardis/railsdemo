class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.integer :snapshot_id
      t.string :src_type
      t.integer :filesize
      t.string :full_url
      t.string :local_path

      t.timestamps
    end
  end
end
