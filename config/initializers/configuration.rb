Workarea::Configuration.define_fields do
  fieldset 'Magento Import', namespaced: false do
    field 'Product Image Base URL',
      type: :string,
      default: nil,
      description: 'Base URL for image importing. For example: "http://yourmagentosite.com/media/catalog/product". The "image" column will be appended to this value and processed as a product image. Images will not be imported if this field is left blank.',
      allow_blank: true

   field 'Image Option Column',
      type: :string,
      default: nil,
      description: 'The column used to determine what option to attach product images to, for example "color". This will allow image switching on PDP. Leaving this field blank will import the images without options.',
      allow_blank: true

    field 'Product Filter Columns',
      type: :string,
      default: nil,
      description: 'Columns to import as filters on the product. Values should be in a comma separated list. For example: "size, color, length". Empty values will be ignored.',
      allow_blank: true

    field 'Product Attributes Columns',
      type: :string,
      default: nil,
      description: 'Columns to import as data attributes for the product. Values should be in a comma separated list, exactly as listed in the column of the export. For example: decor_type, sleeve_length, fit',
      allow_blank: true
  end
end
