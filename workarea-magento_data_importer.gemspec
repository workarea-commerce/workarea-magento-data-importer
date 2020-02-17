$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "workarea/magento_data_importer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "workarea-magento_data_importer"
  spec.version     = Workarea::MagentoDataImporter::VERSION
  spec.authors     = ["Jeff Yucis"]
  spec.email       = ["jyucis@workarea.com"]
  spec.homepage    = "http://github.com/workarea-commerce"
  spec.summary     = "Magento Product Importer."
  spec.description = "Imports Magento product data to the Workarea catalog"
  spec.license     = "Business Software License"

  spec.files = `git ls-files`.split("\n")

  spec.add_dependency 'workarea', '~> 3.5.x'
end
