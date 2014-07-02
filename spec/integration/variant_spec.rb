require 'spec_helper'

module Spree
  class WishedProduct
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :variant_id

    def persisted?
      false
    end
  end
end

describe 'variant options' do

  context 'with inventory tracking' do

    before(:each) do
      Spree::VariantConfiguration.track_inventory_levels = true

      @product = create(:product)
      @size = create(:option_type)
      @color = create(:option_type, :name => "Color")
      @s = create(:option_value, :presentation => "S", :option_type => @size)
      @m = create(:option_value, :presentation => "M", :option_type => @size)
      @red = create(:option_value, :name => "Color", :presentation => "Red", :option_type => @color)
      @green = create(:option_value, :name => "Color", :presentation => "Green", :option_type => @color)
      
      @variant1 = create(:variant, :product => @product, :option_values => [@s, @red])
      @variant2 = create(:variant, :product => @product, :option_values => [@s, @green])
      @variant3 = create(:variant, :product => @product, :option_values => [@m, @red])
      @variant4 = create(:variant, :product => @product, :option_values => [@m, @green])

      # implicitly creates stock items for each variant
      location = Spree::StockLocation.first_or_create! name: 'default'
      location.active = true
      location.country =  Spree::Country.where(iso: 'US').first
      location.save!

      # default is true, rather than overriding factory
      Spree::StockItem.update_all :backorderable => false

      # adjust stock items count on hand
      [@variant1, @variant2, @variant3].each do |variant|
        variant.stock_items.each { |stock_item| Spree::StockMovement.create(:quantity => 0, :stock_item => stock_item) }
      end
      @variant4.stock_items.each { |stock_item| Spree::StockMovement.create(:quantity => 1, :stock_item => stock_item) }

      Spree::VariantConfiguration.default_instock = false
    end

    it 'should disallow choose out of stock variants' do
      Spree::VariantConfiguration.allow_select_outofstock = false

      visit spree.product_path(@product)

      # variant options are not selectable
      within("#product-variants") do
        size = find_link('S')
        size.click
        assert !size["class"].include?("selected")
        color = find_link('Green')
        color.click
        assert !color["class"].include?("selected")
      end

      # add to cart button is still disabled
      assert find_button("Add To Cart", :disabled => true).disabled?
      # add to wishlist button is still disabled
      assert find_button("Add To Wishlist", :disabled => true).disabled?
    end

    it 'should allow choose out of stock variants' do
      Spree::VariantConfiguration.allow_select_outofstock = true

      visit "/products/#{@product.slug}"

      # variant options are selectable
      within("#product-variants") do
        size = find_link('S')
        size.click
        assert size["class"].include?("selected")
        color = find_link('Green')
        color.click
        assert color["class"].include?("selected")
      end
      # add to cart button is still disabled
      assert find_button("Add To Cart", :disabled => true).disabled?
      # add to wishlist button is enabled
      assert !find_button("Add To Wishlist").disabled?
    end

    it "should choose in stock variant" do
      visit "/products/#{@product.slug}"
      within("#product-variants") do
        size = find_link('M')
        size.click
        assert size["class"].include?("selected")
        color = find_link('Green')
        color.click
        assert color["class"].include?("selected")
      end
      # add to cart button is enabled
      assert !find_button("Add To Cart").disabled?
      # add to wishlist button is enabled
      assert !find_button("Add To Wishlist").disabled?
    end

    it "should select first instock variant when default_instock is true" do
      Spree::VariantConfiguration.default_instock = true

      visit "/products/#{@product.slug}"

      within("#product-variants") do
        size = find_link('M')
        assert size["class"].include?("selected")
        color = find_link('Green')
        assert color["class"].include?("selected")
      end

      # add to cart button is enabled
      assert !find_button("Add To Cart").disabled?
      within("span.price.selling") do
        assert page.has_content?("$#{@variant4.price}")
      end
    end

    def teardown
      # reset preferences to default values
      Spree::VariantConfiguration.allow_select_outofstock = false
      Spree::VariantConfiguration.default_instock = false
    end
  end

  context 'without inventory tracking' do
    before(:each) do
      Spree::VariantConfiguration.track_inventory_levels = false

      @product = create(:product)
      @size = create(:option_type)
      @color = create(:option_type, :name => "Color")
      @s = create(:option_value, :presentation => "S", :option_type => @size)
      @red = create(:option_value, :name => "Color", :presentation => "Red", :option_type => @color)
      @green = create(:option_value, :name => "Color", :presentation => "Green", :option_type => @color)
      @variant1 = create(:variant, :product => @product, :option_values => [@s, @red])
      @variant2 = create(:variant, :product => @product, :option_values => [@s, @green])
    end

    it "should choose variant with track_inventory_levels to false" do
      visit "/products/#{@product.slug}"
      within("#product-variants") do
        size = find_link('S')
        size.click
        assert size["class"].include?("selected")
        color = find_link('Red')
        color.click
        assert color["class"].include?("selected")
      end
      # add to cart button is enabled
      assert !find_button("Add To Cart").disabled?
      # add to wishlist button is enabled
      assert !find_button("Add To Wishlist").disabled?
    end
  end

end
