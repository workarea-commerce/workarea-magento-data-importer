module Workarea
  module MagentoDataImporter
    class SimpleProduct < BaseProduct
      attr_reader :magento_product, :product_data

      def process
        # only set the name if this is the primary row, not a supporting row
        # with only categories or aditional images and filters
        if primary_row?
          product.assign_attributes(product_attributes)
        end

        existing_filters = product.filters
        new_filters = row_filters(product_data)

        new_product_filters = add_filter_values(existing_filters, new_filters)

        filters = category_filters.merge(new_product_filters)
        product.filters = filters

        product_details = build_product_details(product_data)
        product.update_details(product_details)

        product.save! rescue puts "Error saving #{magento_product.magento_product_id}"

        if product_data[:sku].present?
          sku = product_data[:sku].parameterize
          create_variant(sku)
          create_inventory_sku(sku)
          create_pricing_sku(sku)
        end

        create_categories

        create_redirect(product_data)

        build_image(product_data)
        magento_product.update_attributes!(imported: true)
      end

      private

      def primary_row?
        product_data[:name].present?
      end

      def create_inventory_sku(sku)
        inventory_sku = Workarea::Inventory::Sku.find_or_initialize_by(id: sku)
        inventory_sku.available = product_data[:qty] || 0
        inventory_sku.policy = "standard"
        inventory_sku.save! rescue puts "Inventory #{sku} variant could not be saved"
      end

      def create_pricing_sku(sku)
        pricing_sku = Workarea::Pricing::Sku.find_or_initialize_by(id: sku)
        msrp = product_data[:msrp].to_m
        pricing_sku.msrp = msrp if msrp > 0.to_m
        pricing_sku.prices = [{ regular: product_data[:price].to_m }]
        pricing_sku.save! rescue puts "Pricing #{sku} variant could not be saved"
     end

      def create_variant(sku)
        variant = product.variants.find_or_initialize_by(sku: sku)
        variant.name = sku

        options = row_filters(product_data)
        variant.update_details(options)
        variant.save! rescue puts "Variant #{sku} could not be saved"
      end
    end
  end
end
