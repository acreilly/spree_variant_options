module SpreeVariantOptions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      
      desc "Installs required migrations for spree_variant_options"

      def copy_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_variant_options'
      end
      
      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', '//= require spree_variant_options\n'
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', '*= require spree_variant_options\n', :before => /\*\//, :verbose => true
      end

    end
  end
end
