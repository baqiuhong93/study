class Cart
  
  attr_accessor :cartItem
  
  def initialize
    @cartItem = {}
  end
  
  def add(cart_item,is_plus=false)
    if @cartItem.has_key?(cart_item.id)
      if is_plus
        @cartItem[cart_item.id] = @cartItem[cart_item.id]
      end
    else
      @cartItem[cart_item.id] = cart_item
    end
    @cartItem[cart_item.id]
  end
  
  def remove(id)
    if @cartItem.has_key?(id.to_i)
      @cartItem.delete(id.to_i)
    end
  end
  
  def clear
    @cartItem.clear
  end
  
  def get_cart_item
    cart_item_a = []
    @cartItem.each_value do |value|
      cart_item_a.push(value.id)
    end
    cart_item_a.join(',')
  end
  
  def empty?
    @cartItem.empty?
  end
  
  def get_amount
    amount = 0
    @cartItem.each_value do |value|
      amount = amount + value.sale_price_mul_num
    end
    amount
  end
end