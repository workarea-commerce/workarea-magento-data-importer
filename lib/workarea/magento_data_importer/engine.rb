require 'workarea/magento_data_importer'

module Workarea
  module MagentoDataImporter
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::MagentoDataImporter
    end
  end
end
