module Workarea
  module MagentoDataImporter
    class BaseProduct
      module ProductUrl
        include Workarea::I18n::DefaultUrlOptions
        include Storefront::Engine.routes.url_helpers
        extend self
      end

      attr_reader :magento_product, :product_data, :product

      def initialize(magento_product)
        @magento_product = magento_product
        @product_data = magento_product.product_data.deep_symbolize_keys
        @product = Workarea::Catalog::Product.find_or_initialize_by(id: magento_product.magento_product_id)
      end

      private

      # Converts the row's product data into a hash of data to be used in creating
      # and updating the product information.
      #
      # @return [Hash]
      def product_attributes
        {
          name: product_data[:name],
          description:  product_data[:description],
          meta_description: product_data[:meta_description],
        }
      end

      # Converts the row's product data into a hash of filters.
      #
      # @param attrs [Hash] the rows product data
      # @return [Hash]
      def row_filters(attrs)
        return if ENV["product_filter_columns"].blank?
        filter_columns = ENV["product_filter_columns"]
        headers = filter_columns.split(",")

        filters = {}

        headers.each do |header|
          k = header.to_sym
          v = attrs[k]
          if v.present?
            filters[k] = v
          end
        end
        filters
      end

      # Adds a hash to an existing set of product filters
      #
      # @param existing_filters [Hash] the set of existing product filters
      # @param new_filters [Hash] new filters to add
      # @return [Hash]
      def add_filter_values(existing_filters, new_filters)
        return existing_filters unless new_filters.present?

        new_filters.each do |k, v|
          if existing_filters.key?(k)
            existing_filters[k] << v
            existing_filters[k].uniq!
          else
            existing_filters[k] = [v]
          end
        end
        existing_filters
      end

      # Creates a hash based on the product data's category value, data is split
      # on "/" which is the default seperator in the magento export
      #
      # @return [Hash]
      def category_filters
        if product_data[:_category].present?
          { category: product_data[:_category].split('/') }
        else
          {}
        end
      end

      # Creates a hash based on the configured product attributes columns
      #
      # @param attrs [Hash] a hash of magento product data
      # @return [Hash]
      def build_product_details(attrs)
        return if ENV["product_attributes_columns"].blank?
        details_columns = ENV["product_attributes_columns"]

        headers = details_columns.split(",")

        details = {}

        headers.each do |header|
          k = header.to_sym
          v = attrs[k]
          if v.present?
            details[k] = v
          end
        end
        details
      end

      # Creates a hash based on the configured product attributes columns
      #
      # @param attrs [Hash] a hash of magento product data
      # @return [Hash]
      def create_categories
        return unless product_data[:_category].present?

        product_data[:_category].split('/').each do |category_name|
          category = Workarea::Catalog::Category.find_or_create_by(name: category_name)
          category.product_ids << product.id unless category.product_ids.include?(category.id)
          category.save!
        end
      end

      # Creates a Workarea::Catalog::ProductImage based on a magento export row
      #
      # @param attrs [Hash] a hash of magento product data
      # @return [Bool]
      def build_image(attrs)
        return unless ENV["product_image_base_url"].present? && attrs[:image].present?

        return if attrs[:image] == "no_selection"

        product_image_base_url = ENV["product_image_base_url"]
        option_column = ENV["image_option_column"]

        image_path = product_image_base_url + attrs[:image]

        option = option_column.present? ? attrs[option_column.to_sym] : nil

        image_attributes = {
          position: attrs[:_media_position],
          image_url: image_path,
          option: option
        }

        existing_image = product.images.detect { |i| i.image_name == attrs[:image].split('/').last }

        begin
          if existing_image.present?
            existing_image.update_attributes!(
              image_attributes
            )
            return
          else
            image = product.images.build(image_attributes)
            image.save!
          end
        rescue
          puts "Error creating image #{attrs[:image]}"
        end
      end

      # Creates a redirect based on the attributes url_path
      #
      # @param attrs [Hash] a hash of magento product data
      # @return [Workarea::Navigation::Redirect]
      def create_redirect(attrs)
        return unless attrs[:url_path].present?
        path = attrs[:url_path]
        destination = ProductUrl.product_path(product)

        Workarea::Navigation::Redirect.create(path: path, destination: destination)
      end
    end
  end
end
