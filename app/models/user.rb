# encoding: utf-8
class User < ActiveRecord::Base
  
  after_initialize :default_values
  after_update :delete_cache
  
  self.primary_key = "uid"
  attr_accessible :uid, :email, :name, :balance, :gender, :full_name, :mobile_phone, :address, :salt, :avatar_path, :ajax_key
  has_many :user_accounts
  has_many :user_classworks
  has_many :orders
  has_many :used_card_nos
  has_many :notes
  has_many :user_money_records
  
  def self.gender_hash
    {1 => "男", 2 => "女"}
  end
  
  def security_key
    Digest::MD5.hexdigest(self.uid.to_s + "_" + self.salt + "_" + DateTime.now.strftime("%Y%m%d"))
  end
  
  def self.find_from_cache(id)
    APP_CACHE.fetch("users_#{id}", 0) do
      User.where("uid = ?", id).first
    end
  end
  
  def now_balance
    _user = User.where("uid = ?", self.uid).first
    _user.nil? ? 0.00 : _user.balance
  end
  
  private
  
  def default_values
    if self.new_record?
      self.balance = 0 if self.balance.nil?
      self.gender = 0 if self.gender.nil?
      self.full_name = '' if self.full_name.nil?
      self.mobile_phone = '' if self.mobile_phone.nil?
      self.address = '' if self.address.nil?
      self.avatar_path = '' if self.avatar_path.nil?
    end
  end
  
  def delete_cache
    APP_CACHE.delete("users_#{self.id}")
  end
end
