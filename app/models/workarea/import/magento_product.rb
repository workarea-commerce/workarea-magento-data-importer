module Workarea
  module Import
    class MagentoProduct
      include ApplicationDocument

      field :product_data, type: Hash
      field :magento_product_id, type: String
      field :product_type, type: String
      field :associated_product_id, type: String
      field :imported, type: Boolean

      index({ product_type: 1 })
      index({ magento_product_id: 1 })
      index({ associated_product_id: 1 })
      index({ imported: 1 })

      scope :parent_products, -> { where(product_type: "configurable") }
      scope :simple_products, -> { where(:product_type.ne => "configurable") }
    end
  end
end
