# encoding: utf-8
class UserAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  belongs_to :order_item
  belongs_to :product

  has_paper_trail
  
  attr_accessible :effect_str, :effect_type, :product_type, :status, :user_id, :user_name, :product_id, :product_name, :order_id, :order_code, :order_item_id
  
  def self.status_hash
    {1 => "有效", -1 => "无效"}
  end
  
  def reversion_status
    if self.status == 1
      update_attribute(:status, -1)
    else
      update_attribute(:status, 1)
    end
  end
  
  def effective?
    return false if self.effect_str.nil?
    return false if self.status == -1
    
    effect_strs = self.effect_str.split(" ")
    return false if effect_strs.length != 2
    
    dates = effect_strs[0].split("-")
    times = effect_strs[1].split(":")
    effect_date = DateTime.new(dates[0].to_i,dates[1].to_i,dates[2].to_i,times[0].to_i,times[1].to_i,times[2].to_i)
    return false if effect_date.to_i <= DateTime.now.to_i
    
    return true
  end
end
