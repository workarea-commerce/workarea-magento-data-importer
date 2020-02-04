module Workarea
  module MagentoDataImporter
    class ConfigurableProduct < BaseProduct
      attr_reader :magento_product, :product_data

      def process
        product.assign_attributes(product_attributes)
        product.filters = category_filters

        product_details = build_product_details(product_data)
        product.update_details(product_details)

        product.save! rescue puts "Error saving #{magento_product.magento_product_id}"

        create_variants

        create_categories

        create_redirect(product_data)

        magento_product.update_attributes!(imported: true)
      end

      private

      def variant_details_row(products)
        products.detect { |p| p.product_data[:price].present? }
      end

      def variant_products
        @variant_products ||= Workarea::Import::MagentoProduct.where(magento_product_id: magento_product.magento_product_id)
      end

      def create_variants
        variant_products.each_with_index do |variant_product, variant_position = 1|
          variant_product_data = variant_product.product_data.deep_symbolize_keys

          next unless variant_product_data[:_super_products_sku].present?

          sku = variant_product_data[:_super_products_sku].parameterize

          # the "super_products_sku" field points to a record with the required details
          detail_products = associated_products(variant_product_data[:_super_products_sku])

          # get the record with the pricing and inventory
          details_row = variant_details_row(detail_products)

          # create the variant sku
          variant = product.variants.find_or_initialize_by(sku: sku)
          variant.name = variant_product_data[:sku]

          options = row_filters(variant_product_data)
          variant.update_details(options)

          variant.save! rescue (puts "#{sku} variant could not be saved" && next)

          pricing_sku = Workarea::Pricing::Sku.find_or_initialize_by(id: sku)

          msrp = details_row.product_data[:msrp].to_m
          pricing_sku.msrp = msrp if msrp > 0.to_m
          pricing_sku.prices = [{ regular: details_row.product_data[:price].to_m }]
          pricing_sku.save! rescue (puts "pricing #{sku} variant could not be saved" && next)

          # create the inventory sku
          inventory_sku = Workarea::Inventory::Sku.find_or_initialize_by(id: sku)
          inventory_sku.available = details_row.product_data[:qty] || 0
          inventory_sku.policy = "standard"
          inventory_sku.save! rescue (puts "inventory #{sku} variant could not be saved" && next)

          detail_product_filters = product.filters
          detail_products.each do |detail_product|
            detail_product_data = detail_product.product_data.deep_symbolize_keys
            build_image(detail_product_data)

            new_filters = row_filters(detail_product_data)
            detail_product_filters = add_filter_values(detail_product_filters, new_filters)

            detail_product.imported = true
            detail_product.save!

            create_redirect(detail_product_data)
          end

          product.filters = detail_product_filters
          product.save!

          create_redirect(variant_product_data)

          variant_product.update_attributes!(imported: true)
        end
      end

      def associated_products(sku)
        Workarea::Import::MagentoProduct.where(magento_product_id: sku)
      end
    end
  end
end
