module Workarea
  module Factories
    module MagentoDataFile
      Factories.add(self)

      def magento_products_csv_path
        "#{Workarea::MagentoDataImporter::Engine.root}/test/fixtures/magento_products.csv"
      end
    end
  end
end
