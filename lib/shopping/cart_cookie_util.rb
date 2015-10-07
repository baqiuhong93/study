class CartCookieUtil
  
  SHOPPING_SESSION_CART_NAME = '_shopping_cart'
  
  SHOPPING_COOKIE_CART_NAME = '_shopping_cookie_cart'
  
  def self.get_cart(session,cookies)
    cart = session[SHOPPING_SESSION_CART_NAME]
    if cart.nil?
      cookie_cart = cookies[SHOPPING_COOKIE_CART_NAME]
      if !cookie_cart.nil?
        cart = Cart.new
        cookie_cart_arr = cookie_cart.split(',')
        cookie_cart_arr.each do |value|
          product = Product.find(value)
          cart.add(CartItem.new(product)) unless product.nil?
        end
        session[SHOPPING_SESSION_CART_NAME] = cart
      else
        cart = Cart.new
      end
    end
    cart
  end
  
  def self.add_to_cart(session,cookies,id)
    cart = self.get_cart(session,cookies)
    product = Product.find_from_cache(id)
    if !product.nil?
      add_cart_item = CartItem.new(product)
      cart.add(add_cart_item)
      session[SHOPPING_SESSION_CART_NAME] = cart
      cookies[SHOPPING_COOKIE_CART_NAME] = cart.get_cart_item
    end
  end
  
  def self.remove_from_cart(session, cookies, id)
    cart = self.get_cart(session,cookies)
    cart.remove(id)
    session[SHOPPING_SESSION_CART_NAME] = cart
    cookies[SHOPPING_COOKIE_CART_NAME] = cart.get_cart_item
  end
  
  def self.clear_cart(session, cookies)
    cart = self.get_cart(session,cookies)
    cart.clear
    session[SHOPPING_SESSION_CART_NAME] = cart
    cookies[SHOPPING_COOKIE_CART_NAME] = cart.get_cart_item
  end
end