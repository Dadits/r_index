class CreatePackageMaintaner < ActiveRecord::Migration
  def change
    create_table :package_maintaners do |t|
      t.string :name
      t.string :email
      
      t.integer :package_version_id
    end
  end
end
