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
            product_type: row[:_type],
            associated_product_id: row[:_super_products_sku]
          )
        end

        Sidekiq::Callbacks.disable do
          Workarea::Import::MagentoProduct.parent_products.each do |parent_product|
            MagentoDataImporter::ConfigurableProduct.new(parent_product).process
          end
          Workarea::Import::MagentoProduct.where(imported: true).delete_all

          Workarea::Import::MagentoProduct.simple_products.each do |simple_product|
            MagentoDataImporter::SimpleProduct.new(simple_product).process
          end
          Workarea::Import::MagentoProduct.where(imported: true).delete_all
        end
      end

      private

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
