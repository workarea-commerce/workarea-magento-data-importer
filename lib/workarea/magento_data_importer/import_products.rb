module Workarea
  module MagentoDataImporter
    class ImportProducts
      def self.import!(file_path)
        # purge existing data
        Workarea::Import::MagentoProduct.delete_all

        current_id = nil

        CSV.foreach(file_path, csv_options) do |row|
          current_id = row[:sku] if row[:sku].present?

          Workarea::Import::MagentoProduct.create!(
            product_data: row.to_hash,
            magento_product_id: current_id,
            product_type: row[:_type]
          )
        end

        Sidekiq::Callbacks.disable do
          process_configurable_products
          process_simple_products
        end
      end

      private

      def self.process_configurable_products
        Workarea::Import::MagentoProduct.parent_products.each do |parent_product|
          begin
            MagentoDataImporter::ConfigurableProduct.new(parent_product).process
          rescue
            puts "Error importing product #{parent_product.magento_product_id}"
            parent_product.update_attributes!(import_failed: true)
          end
        end
        Workarea::Import::MagentoProduct.where(imported: true).delete_all
      end

      def self.process_simple_products
        Workarea::Import::MagentoProduct.simple_products.each do |simple_product|
          begin
            MagentoDataImporter::SimpleProduct.new(simple_product).process
          rescue
            puts "Error importing product #{simple_product.magento_product_id}"
            simple_product.update_attributes!(import_failed: true)
          end
        end
        Workarea::Import::MagentoProduct.where(imported: true).delete_all
      end

      def self.csv_options
        {
          headers: true,
          return_headers: false,
          header_converters: -> (h) { h.underscore.optionize.to_sym }
        }
      end
    end
  end
end
