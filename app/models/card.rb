# encoding: utf-8

class Card < ActiveRecord::Base
  
  has_many :card_nos

  has_paper_trail
  
  attr_accessible :card_type, :description, :expired_at, :group, :name, :onlined_at, :price, :status, :total_num, :product_ids, :select_num, :must_num, :products, :used_num
  
  def is_yihao?
    if self.card_type == 2
      true
    else
      false
    end
  end
  
  def is_tonghao?
    !is_yihao?
  end
  
  def self.card_type_hash
    {1 => "同号卡", 2 => "异号卡"}
  end
  
  def self.group_hash
    {1 => "礼品卡", 2 => "套装卡", 3 => "渠道卡", 4 => "充值卡"}
  end
  
  def chongzhika?
    self.group == 4 ? true : false
  end
  
  def product_array
    if self.products.nil? || self.products.empty?
      []
    else
      eval(self.products.gsub(":","=>"))
    end
  end
  
  def online?
    return true if self.onlined_at.nil?
    if DateTime.now >= self.onlined_at
      return true
    else
      return false
    end
  end
  
  def expired?
    return false if self.expired_at?
    if DateTime.now >= self.expired_at
      return true
    else
      return false
    end
  end
end
