module Workarea
  module Import
    class MagentoProduct
      include ApplicationDocument

      field :product_data, type: Hash
      field :magento_product_id, type: String
      field :product_type, type: String
      field :imported, type: Boolean
      field :import_failed, type: Boolean, default: false

      index({ product_type: 1 })
      index({ magento_product_id: 1 })
      index({ imported: 1 })
      index({ import_failed: 1 })

      scope :parent_products, -> { where(product_type: "configurable").where(import_failed: false) }
      scope :simple_products, -> { where(:product_type.ne => "configurable").where(import_failed: false) }
    end
  end
end
