# encoding: utf-8
class UserClasswork < ActiveRecord::Base
  
  after_initialize :default_values
  
  belongs_to :classwork
  belongs_to :user
  
  attr_accessible :admin_user_id, :admin_user_name, :classwork_id, :classwork_name, :status, :answer_text, :answer_file, :product_id, :product_name, :user_id, :user_name, :reply_text, :reply_file
  
  def self.status_hash
    {1 => "待批改", 2 => "批改中", 3 => "已批改"}
  end
  
  def weitijiao?
    if self.status == 0
      true
    else
      false
    end
  end
  
  def status_text
    if self.status == 0
      "未提交"
    elsif self.status == 1
      "待批改"
    elsif self.status == 2
      "批改中"
    elsif self.status == 3
      "已批改"
    else
      "---"
    end
  end
  
  def write?
    if self.status == 0 || self.status == 1
      true
    else
      false
    end
  end
  
  private
  
  def default_values
    if self.new_record?
      self.status = 1 if self.status.nil?
      self.admin_user_id = 0 if self.admin_user_id.nil?
      self.admin_user_name = '' if self.admin_user_name.nil?
      self.answer_text = '' if self.answer_text.nil?
      self.answer_file = '' if self.answer_file.nil?
      self.reply_text = '' if self.reply_text.nil?
      self.reply_file = '' if self.reply_file.nil?
      self.score = 0 if self.score.nil?
    end
  end
  
end
