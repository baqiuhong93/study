# encoding: utf-8
class Classwork < ActiveRecord::Base
  
  after_initialize :default_values
  after_update :delete_cache
  
  attr_accessible :name, :demand, :start_at, :end_at, :deleted, :work_num
  
  def self.find_from_cache(id)
    APP_CACHE.fetch("classwork_#{id}", 0) do
      Classwork.where("id = ?", id).first
    end
  end
  
  def deleted_text
    if self.deleted
      '无效'
    else
      '有效'
    end
  end
  
  def effective?
    if self.deleted
      return false
    else
      if DateTime.now.to_i < self.start_at.to_i || DateTime.now.to_i > self.end_at.to_i
        return false
      end
      return true
    end
  end
  
  def self.deleted_hash
    {false => "有效", true => "无效"}
  end
  
  private
  
  def default_values
    if self.new_record?
      self.work_num = 0 if self.work_num.nil?
      self.deleted = 0 if self.deleted.nil?
    end
  end
  
  def delete_cache
    APP_CACHE.delete("classwork_#{self.id}")
  end
end
