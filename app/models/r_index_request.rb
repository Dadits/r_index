require 'rubygems/package'
require 'zlib'
require 'open-uri'
require "dcf"
OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
OpenURI::Buffer.const_set 'StringMax', 0
class RIndexRequest
  include HTTParty
  
  base_uri "http://cran.r-project.org/src/contrib"
  
  def build_packages
    sliced_packages = self.class.get("/PACKAGES").body.split("\n\n")
    sliced_packages.first(2).each do |string_package|
      package_properties_hash = convert_to_hash(string_package)
      package_name = package_properties_hash["Package"]
      manage_packages(load_package(package_name, package_properties_hash["Version"]))
    end
  end
    
  private
  
    def manage_versions(params)
      p "==="
      p params
      current_package = Package.find_by(name: params[:package_name])
      current_package.present? ? sync_package_versions(params) : create_new_package(params)
    end
  
    def sync_package_versions(params)
      
    end
    
    def create_new_package(params)
      package = Package.create(name: params[:package_name], title: params[:title])
      package_version = package.versions.create(
                              name: params[:version], 
                       description: params[:description],
                           license: params[:license],
                  r_version_needed: params[:r_version_needed],
                      dependencies: params[:dependencies],
                  date_publication: params[:date_publication]
                  )
      params[:authors].each do |author|
        package_version.authors.create(name: author[:name], email: author[:email])
      end
      params[:maintaners].each do |maintaner|
        package_version.maintaners.create(name: author[:name], email: author[:email])
      end
    end
  
    def initialize(params = {})
      @options = params
    end
    
    def load_package(name, version)
      uri = "http://cran.r-project.org/src/contrib/#{ name }_#{ version }.tar.gz"
      source = open(uri)
    end
    
    def manage_packages(package)
      tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(package))
      tar_extract.rewind
      tar_extract.each do |entry|
        if entry.file? && entry.full_name.include?('DESCRIPTION')
          contents = convert_to_hash(entry.read)
          manage_versions(prepare_params(contents))
        end
      end
      tar_extract.close
    end
    
    def convert_to_hash(s)
      s.gsub(/\n\s+/, ' ').split("\n").map { |v| Dcf.parse(v).first }.inject(:merge)
    end
    
    def prepare_params(contents)
      { description: contents['Description'], 
            authors: prepare_authors(contents['Author']), 
         maintaners: prepare_maintaners(contents["Maintainer"]),
            version: contents["Version"],
       dependencies: contents["Depends"],
            license: contents["License"],
   r_version_needed: contents["Depends"].include?("R"),
       package_name: contents["Package"],
        suggestions: contents["Suggests"],
   date_publication: contents["Date"],
              title: contents["Title"]}
    end
    
    def prepare_authors(s)
      
    end
      
end