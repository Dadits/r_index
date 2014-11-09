class CreatePackageVersion < ActiveRecord::Migration
  def change
    create_table :package_versions do |t|
      t.string :name
      t.string :license
      t.string :dependencies

      t.integer :package_id

      t.text :description

      t.boolean :r_version_needed
      
      t.date :date_publication
    end
  end
end
