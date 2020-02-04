require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::MagentoDataImporter::Engine.root
  Workarea::Teaspoon.apply(config)
end
