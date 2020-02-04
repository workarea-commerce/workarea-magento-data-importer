begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Magento Data Importer'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'
load 'workarea/changelog.rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end
task default: :test

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'workarea/magento_data_importer/version'

desc "Release version #{Workarea::MagentoDataImporter::VERSION} of the gem"
task :release do
  Rake::Task['workarea:changelog'].execute
  system 'git add CHANGELOG.md'
  system 'git commit -m "Update CHANGELOG"'
  system 'git push origin HEAD'

  system "git tag -a v#{Workarea::MagentoDataImporter::VERSION} -m 'Tagging #{Workarea::MagentoDataImporter::VERSION}'"
  system 'git push --tags'

  system "gem build workarea-magento_data_importer.gemspec"
  system "gem push workarea-magento_data_importer-#{Workarea::MagentoDataImporter::VERSION}.gem"
  system "rm workarea-magento_data_importer-#{Workarea::MagentoDataImporter::VERSION}.gem"
end

desc 'Run the JavaScript tests'
ENV['TEASPOON_RAILS_ENV'] = File.expand_path('../test/dummy/config/environment', __FILE__)
task teaspoon: 'app:teaspoon'

desc 'Start a server at http://localhost:3000/teaspoon for JavaScript tests'
task :teaspoon_server do
  Dir.chdir("test/dummy")
  teaspoon_env = File.expand_path('../test/teaspoon_env.rb', __FILE__)
  system "RAILS_ENV=test TEASPOON_ENV=#{teaspoon_env} rails s"
end
