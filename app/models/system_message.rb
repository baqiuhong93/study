# encoding: utf-8
class SystemMessage
  
  include Mongoid::Document
  field :user_id, type: Integer
  field :user_name, type: String
  field :admin_user_id, type: Integer
  field :admin_user_name, type: String
  field :type, type: Integer
  field :content, type: String
  field :created_at, type: DateTime
  
  
  def self.type_hash
    {1 => "系统消息", 2 => "学习提醒"}
  end
end