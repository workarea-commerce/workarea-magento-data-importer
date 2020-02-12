module Workarea
  module MagentoDataImporter
    class Taxonomy
      attr_reader :magento_categories

      def initialize(magento_categories)
        @magento_categories = magento_categories
      end

      def process
        categories_array = magento_categories.split("/")
        parent = Workarea::Navigation::Taxon.root

        i = 0
        max_size = categories_array.size - 1

        while i <= max_size do
          client_id = categories_array[0..i].join("/")
          workarea_category = Workarea::Catalog::Category.where(client_id: client_id).first

          taxon = Workarea::SaveTaxonomy.build(workarea_category)

          save = Workarea::SaveTaxonomy.new(taxon, { parent_id: parent.id })
          save.perform

          parent = taxon
          i += 1
        end
      end
    end
  end
end
