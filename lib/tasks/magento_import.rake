namespace :workarea do
  namespace :magento do
    desc 'Import Magento Catalog Data'
    task import_products: :environment do
      require 'workarea/seeds'

      Workarea::Seeds.puts_with_color "== Starting Magento Products Migration", :yellow

      raise 'No File provided' if ARGV.length < 2

      file_path = ARGV.second

      Workarea::MagentoDataImporter::ImportProducts.import!(file_path)

      Workarea::Seeds.puts_with_color "\n== Updating Elasticsearch data", :yellow
      Rake::Task['workarea:search_index:all'].invoke
    end
  end
end
