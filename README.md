Workarea Magento Data Importer
================================================================================

Magento Data Importer plugin that allows migration of standard 1.X Magento Product exports to the Workarea Commerce system.

Overview
--------------------------------------------------------------------------------

* Provides a rake task to import product data magento exports.
* Supports Configurable and Simple Magento product types.


Getting Started
--------------------------------------------------------------------------------

Add the gem to your application's Gemfile specifying the source:

    # ...
    gem 'workarea-magento_data_importer'
    # ...

Update your application's bundle.

    cd path/to/application
    bundle


To run this import you will first need to export your products out of the Magento admin.

1. Log into the Magento admin.
2. Go to "System" -> "Import/Export" -> "Export" in the top navigation menu.
3. Select "Products" from the "Entity Type" select. Leave the format as CSV.
4. Do not use the "skip" check box on any of the fields that display.
5. Click "Continue", your download should start soon.

Run the Workarea import by passing the path to the Magento export CSV file as an argument.

```bash
bin/rails workarea:magento:import_products  /data/YOUR_EXPORT_FILE.csv
```

Because the import data can not be imported sequentially the CSV is first saved to a mongo collection:

```ruby
Workarea::Import::MagentoProduct
```
After the data is imported into a collection the process will first import configurable products then simple products. The host app's Elasticsearch index will be re-indexed after completion. Any records that are not successfully processed will remain in the import collection where they can be inspected.

The following data is imported:
* Products and their associated variants
* Inventory
* Pricing
* Product images
* Categories
* Redirects based on the URL key in the export


Configuration
--------------------------------------------------------------------------------
The following is configurations can be passed as ENV vars to the rake task


**Product Image Base URL**
Optional. The absolute url that prepends your product images. For example "http://yourmagentosite.com/media/catalog/product". Required for importing images.
Example: product_image_base_url="http://yourmagentosite.com/media/catalog/product"

**Image Option Column**
Optional. The column in the export to attach images to. This will allow for image switching on the PDP.
Example: image_option_column="color"

**Product Filter Columns**
Optional. The columns to import as filters for the products. For example: "color,size,length". Empty values will not be imported as a filter.
Example: product_filter_columns="color,size,length"

**Product Attributes Columns**
Optional. The columns to import as product attributes. This information shows on the product detail page. For example: "country_of_origin,material,part_number". Empty values will not be imported as product data attributes.
Example: product_attributes_columns="country_of_origin,material,part_number"

Workarea Platform Documentation
--------------------------------------------------------------------------------

See [https://developer.workarea.com](https://developer.workarea.com) for Workarea platform documentation.

License
--------------------------------------------------------------------------------

Workarea Magento Data Importer is released under the [Business Software License](LICENSE)
