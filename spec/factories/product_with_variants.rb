FactoryGirl.define do

  factory :product_with_variants, :parent => :product do

    after(:create) { |product|
      size_option_type = Spree::OptionType.find_by_name("size") || create(:option_type, :name => "size", :presentation => "Size")
      color_option_type = Spree::OptionType.find_by_name("color") || create(:option_type,:name => "color", :presentation => "Color")
      sizes = %w(Small Medium Large X-Large).map{ |i| create :option_value, :presentation => i, :option_type => size_option_type }
      colors = %w(Red Green Blue Yellow Purple Gray Black White).map{ |i| create :option_value, :presentation => i, :option_type => color_option_type }

      product.option_types = Spree::OptionType.where(:name => %w(size color))

      variants = sizes.map do |size|
        colors.map { |color| create(:variant, product: product, option_values: [size, color]) }
      end
      product.variants << variants.flatten

    }

  end

end
