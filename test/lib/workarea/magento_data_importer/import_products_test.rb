require 'test_helper'

module Workarea
  module MagentoDataImporter
    class ImportProductsTest < TestCase
      setup :store_env_vars

      def store_env_vars
        @old_product_attributes_columns = ENV["product_attributes_columns"]
        @old_product_filter_columns = ENV["product_filter_columns"]
        @old_image_option_column = ENV["image_option_column"]
      end

      def test_import_products
        ENV["product_attributes_columns"] = 'jewelry_type,gender,frame_syle,electronic_type'
        ENV["product_filter_columns"] = 'color,size'
        ENV["image_option_column"] = 'color'

        Workarea::MagentoDataImporter::ImportProducts.import!(magento_products_csv_path)

        assert_equal(3, Workarea::Catalog::Product.count)

        configurable_product = Workarea::Catalog::Product.find('Pmo000')
        assert_equal("Thomas Overcoat", configurable_product.name)
        assert(5, configurable_product.variants.size)
        sku = configurable_product.variants.first.sku

        assert({ "color" => ["Black"], "size" => ["XS", "S", "M", "L", "XL"] }, configurable_product.filters)
        assert({ "gender" => ["Male"], "apparel_type" => ["Outerwear"] }, configurable_product.details)

        pricing_sku = Workarea::Pricing::Sku.find(sku)
        inventory_sku = Workarea::Inventory::Sku.find(sku)

        assert_equal(590.00, pricing_sku.sell_price.to_f)
        assert_equal(32, inventory_sku.available)

        simple_product = Workarea::Catalog::Product.find('acj003')
        assert_equal("Pearl Stud Earrings", simple_product.name)
        assert_equal(1, simple_product.variants.size)
        assert_equal({ "jewelry_type" => ["Earrings"], "gender" => ["Female"] }, simple_product.details)
        assert_equal({ "color" => ["Ivory"], "import_category" => [["Accessories", "Jewelry"]] }, simple_product.filters)

        categories = Workarea::Catalog::Category.all.map(&:name).sort
        assert_equal(2, Workarea::Catalog::Category.count)
        assert_equal(["Accessories", "Jewelry"], categories)

        assert_equal(3, Workarea::Navigation::Taxon.count)
        taxons = Workarea::Navigation::Taxon.all.map(&:name).sort
        assert_equal(["Accessories", "Home", "Jewelry"], taxons)

        assert_equal(1, Workarea::Navigation::Menu.count)
        menus = Workarea::Navigation::Menu.all.map(&:name)
        assert_equal(["Accessories"], menus)

        assert_equal(8, Workarea::Navigation::Redirect.count)
        assert_equal(0, Workarea::Import::MagentoProduct.count)
      ensure
        ENV["product_attributes_columns"] = @old_product_attributes_columns
        ENV["product_filter_columns"] = @old_product_filter_columns
        ENV["image_option_column"] = @old_image_option_column
      end

      def test_errors_in_process
        csv = IO.read(magento_products_csv_path)
        csv << "acj005,,Jewelry,simple,Accessories/Jewelry,Default Category,base,,,,,,,,,,,Indigo,,Haiti,2013-03-19 18:10:45,,,,,,,,,,,,Female,,,,,,0,,,/a/c/acj004_2.jpg,,Earrings"
        file = create_tempfile(csv, extension: 'csv')
        Workarea::MagentoDataImporter::ImportProducts.import!(file)
        assert_equal(1, Workarea::Import::MagentoProduct.count)
      end
    end
  end
end
