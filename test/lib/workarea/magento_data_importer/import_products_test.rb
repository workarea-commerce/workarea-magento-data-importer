require 'test_helper'

module Workarea
  module MagentoDataImporter
    class ImportProductsTest < TestCase
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
        assert_equal({ "category" => ["Accessories", "Jewelry"], "color" => ["Ivory"] }, simple_product.filters)

        assert_equal(2, Workarea::Catalog::Category.count)
        assert_equal(8, Workarea::Navigation::Redirect.count)
      end
    end
  end
end