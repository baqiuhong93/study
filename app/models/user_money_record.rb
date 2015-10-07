# encoding: utf-8

class UserMoneyRecord < ActiveRecord::Base
  after_initialize :default_values
  
  belongs_to :user

  has_paper_trail

  
  attr_accessible :amount, :order_id, :order_code, :pay_type, :pay_code, :record_type, :status, :user_name, :user_id
  
  def self.record_type_hash
    {1 => "充值", 2 => "消费"}
  end
  
  def self.chongzhi_status_hash
    {1 => "未付款", 2 => "成功"}
  end
  
  def self.xiaofei_status_hash
    {-1 => "无效", 1 => "有效"}
  end
  
  def status_text
    if self.record_type == 1
      UserMoneyRecord.chongzhi_status_hash[self.status]
    elsif self.record_type == 2
      UserMoneyRecord.xiaofei_status_hash[self.status]
    end
  end
  
  def chongzhi?
    self.record_type == 1 ? true : false
  end
  
  def zhifubao?
    (self.pay_type == 10 && Order.pay_code_hash.has_key?(self.pay_code) && Order.pay_code_hash.has_key?("directPay")) ? true : false
  end
  
  def kuaiqian?
    (self.pay_type == 10 && Order.pay_code_hash.has_key?(self.pay_code) && Order.pay_code_hash.has_key?("00")) ? true : false
  end
  
  def weifukuan?
    if self.status == 1
      true
    else
      false
    end
  end
  
  private
  
  def default_values
    if self.new_record? && self.chongzhi?
      self.pay_type = 10 if self.pay_type.nil?
      self.pay_code = GlobalSettings.default_pay_code if self.pay_code.nil?
    end
  end
  
end
