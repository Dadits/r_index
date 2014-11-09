class Package < ActiveRecord::Base
  has_many :versions, class_name: "PackageVersion"
end