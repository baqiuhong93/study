# encoding: utf-8

class CardNo < ActiveRecord::Base
  belongs_to :card

  has_paper_trail
  
  attr_accessible :code, :passwd, :status
  
  def self.status_hash
    {1 => "有效", 2 => "已使用", -1 => "无效"}
  end
  
  def effective?
    if self.status == 1
      return true
    else
      return false
    end
  end
end
