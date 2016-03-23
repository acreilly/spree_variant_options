Spree::Variant.class_eval do

  include ActionView::Helpers::NumberHelper

  def to_hash(current_currency)
    actual_price = self.price_in(current_currency).amount
    {
      :id    => self.id,
      :count => self.stock_items.to_a.sum(&:count_on_hand),
      :price => number_to_currency(actual_price),
      :backorderable => self.stock_items.where(:backorderable => true).any?,
      :special_stock => self.stock_items.where(:special_stock => true).any?
    }
  end

end
