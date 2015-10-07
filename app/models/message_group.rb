class MessageGroup
  include Mongoid::Document
  field :user_id_1, type: Integer
  field :user_name_1, type: String
  field :user_id_2, type: Integer
  field :user_name_2, type: String
  
  field :last_msg_1, type: Hash
  field :last_msg_2, type: Hash
  
  field :unread_count_1, type: Integer
  field :unread_count_2, type: Integer
  
  field :message_count_1, type: Integer
  field :message_count_2, type: Integer
  
  field :user_ids, type: Array
  
  field :created_at, type: DateTime
  field :updated_at, type: DateTime
  
  

end