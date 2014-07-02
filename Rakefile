# encoding: UTF-8
require 'bundler'
Bundler::GemHelper.install_tasks

require 'spree/testing_support/extension_rake'
desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'spree_variant_options'
  ENV['DATABASE'] = 'postgresql'
  Rake::Task['extension:test_app'].invoke
end
