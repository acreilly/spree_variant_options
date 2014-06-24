module Spree
  class SpreeVariantConfiguration < Preferences::Configuration

    preference :allow_backorders, :integer, default: true
    preference :track_inventory_levels, :integer, default: true
    preference :allow_select_outofstock, :integer, default: false
    preference :default_instock, :integer, default: true


  end
end
