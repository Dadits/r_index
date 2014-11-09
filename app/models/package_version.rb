class PackageVersion < ActiveRecord::Base
  belongs_to :package
  
  has_many :authors, class_name: 'PackageAuthor'
  has_many :maintaners, class_name: 'PackageMaintaner'
end