class CartItem
  
  attr_accessor :id, :name, :origin_price, :sale_price, :discount_price, :num, :skxx_id, :effect_str, :description
  
  def initialize(product)
    @id = product.id
    @name = product.name
    @origin_price = product.origin_price
    @sale_price = product.sale_price
    @num = 1
    @discount_price = 0
    @skxx_id = product.skxx_id
    @effect_str = product.effect_str
    @description = product.description
  end
  
  def num_plus
    @num = @num+1
    self
  end
  
  def sale_price_mul_num
    self.sale_price * self.num
  end
  
end