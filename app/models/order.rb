# encoding: utf-8
require 'user_money_record'
class Order < ActiveRecord::Base
  after_initialize :default_values
  
  after_update :minus_user_balance?
  after_update :add_user_balance?
  belongs_to :user
  has_many :order_items
  
  has_paper_trail

  attr_accessible :amount, :balance_amount, :code, :discount_amount, :gift_num, :ip, :item_num, :manage_remark, :order_type, :pay_code, :pay_id, :pay_type, :remark, :status, :user_name, :user_id, :paid_at, :admin_user_id, :admin_user_name, :invoice_name
  
  def self.pay_type_hash
    {1 => "礼品卡", 2 => "套装卡", 3 => "渠道卡", 4 => "充值卡", 5 => "余额", 10 => "支付宝", 20 => "银行汇款", 30 => "上门付款"}
  end
  
  def self.pay_type_front_hash
    #for zhifu bao{40 => "支付宝", 20 => "银行汇款", 30 => "上门付款"}
    {10 => "支付宝", 20 => "银行汇款", 30 => "上门付款"}
  end
  
  def self.pay_code_hash
    {"ICBCB2C" => "工商银行", "CMB" => "招商银行", "ABC" => "农业银行", "POSTGC" => "邮政储蓄", "COMM" => "交通银行", "BOCB2C" => "中国银行", "CEBBANK" => "光大银行", "CITIC" => "中信银行", "SPDB" => "浦发银行", "CMBC" => "民生银行", "CIB" => "兴业银行", "CCB" => "建设银行", "directPay" => "支付宝"}
    #for kuai qian{"ICBC" => "工商银行", "CMB" => "招商银行", "ABC" => "农业银行", "PSBC" => "邮政储蓄", "BCOM" => "交通银行", "BOC" => "中国银行", "CEB" => "光大银行", "CITIC" => "中信银行", "SPDB" => "浦发银行", "CMBC" => "民生银行", "CIB" => "兴业银行", "CCB" => "建设银行", "00" => "快钱"}
  end
  
  def pay_type_text
    self.pay_type == 10 ? Order.pay_code_hash[self.pay_code] : Order.pay_type_hash[self.pay_type]
  end
  
  def self.status_hash
    {-1 => "已取消", 1 => "未付款", 9 => "已到账"}
  end
  
  def can_open_product_order_by_admin?
    (self.status == -1 || self.status == 1) && (self.pay_type == 20 || self.pay_type == 30) ? true : false
  end
  
  def encrypt_str
    Digest::MD5.hexdigest(self.code+"#" + self.created_at.strftime("%Y-%m-%d %H:%M:%S"))
  end
  
  def total_amount
    self.amount-self.balance_amount
  end
  
  def zhifubao?
    (self.pay_type == 10 && Order.pay_code_hash.has_key?(self.pay_code) && Order.pay_code_hash.has_key?("directPay")) ? true : false
  end
  
  def yidaozhang?
    self.status == 9 ? true : false
  end
  
  def kuaiqian?
    (self.pay_type == 10 && Order.pay_code_hash.has_key?(self.pay_code) && Order.pay_code_hash.has_key?("00")) ? true : false
  end
  
  def weifukuan?
    self.status == 1 ? true : false
  end
  
  def yinhanghuikuan?
    self.pay_type == 20 ? true : false
  end
  
  
  def shangmenfukuan?
    self.pay_type == 30 ? true : false
  end

  def open_user_accounts
    self.order_items.each do |order_item|
      product = order_item.product
      user_account = UserAccount.new :user_id => self.user_id, :user_name => self.user_name, :order_id => self.id, :order_item_id => order_item.id, :product_id => product.id, :product_name => product.name, :product_type => product.product_type, :effect_type => product.effect_type, :effect_str => product.effect_str_date, :status => 1, :order_code => self.code
      user_account.save
    end
  end
  
  private
  
  def minus_user_balance?
    if self.balance_amount > 0 && self.user.now_balance >= self.balance_amount
      self.user.update_attribute(:balance, self.user.now_balance-self.balance_amount)
      consume = UserMoneyRecord.new(:amount => self.balance_amount, :order_id => self.id, :order_code => self.code, :status => 1, :user_name => self.user_name, :user_id => self.user_id, :record_type => 2)
      consume.save
    end
    if self.balance_amount > 0 && self.amount == self.balance_amount && self.status != 9
      self.status = 9
      self.paid_at = DateTime.now
      self.pay_type = 5
      self.pay_code = ''
      self.save
    end
  end
  
  def add_user_balance?
    if self.status == -1 && self.balance_amount > 0
      self.user.update_attribute(:balance, self.user.now_balance+self.balance_amount)
      consume = UserMoneyRecord.where("user_id = ? and record_type = 2 and order_id = ?", self.user_id, self.id).first
      consume.update_attribute(:status, -1) unless consume.nil?
      self.balance_amount = 0
      self.save
    end
  end
  
  def default_values
    if self.new_record?
      self.discount_amount = 0 if self.discount_amount.nil?
      self.remark = '' if self.remark.nil?
      self.manage_remark = '' if self.manage_remark.nil?
      self.balance_amount = 0 if self.balance_amount.nil?
      self.gift_num = 0 if self.gift_num.nil?
      self.pay_type = 10 if self.pay_type.nil?
      self.pay_code = GlobalSettings.default_pay_code if self.pay_code.nil?
      self.invoice_name = '' if self.invoice_name.nil?
    end
  end
end
