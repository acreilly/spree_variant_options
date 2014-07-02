module Spree
  class SpreeVariantConfiguration < Preferences::Configuration

    preference :allow_backorders, :boolean, default: true
    preference :track_inventory_levels, :boolean, default: true
    preference :allow_select_outofstock, :boolean, default: false
    preference :default_instock, :boolean, default: true

  end
end
