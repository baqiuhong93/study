# encoding: utf-8

class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  belongs_to :product

  has_paper_trail

  attr_accessible :discount_amount, :is_gift, :origin_price, :product_id, :product_type, :product_name, :sale_price, :status, :user_name, :user_id, :num
  
  def is_gift_show
    if self.is_gift
      '是'
    else
      '否'
    end
  end
  
  def sale_price_mul_num
    self.sale_price * self.num
  end
end
