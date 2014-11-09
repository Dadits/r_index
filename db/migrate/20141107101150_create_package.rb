class CreatePackage < ActiveRecord::Migration

  def change
    create_table :packages do |t|
      t.string :name
      t.string :title
    end
  end

end
