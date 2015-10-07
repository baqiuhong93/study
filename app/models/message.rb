class Message
  include Mongoid::Document
  field :send_id, type: Integer
  field :send_user_name, type: String
  field :send_status, type: Integer
  
  field :receive_id, type: Integer
  field :receive_user_name, type: String
  field :receive_status, type: Integer
  
  field :content, type: String
  
  field :created_at, type: DateTime
  
  field :user_ids, type: Array
  
  def to_hash
    {:send_id => self.send_id, :send_user_name => self.send_user_name, :send_status => self.send_status, :receive_id => self.receive_id, :receive_user_name => self.receive_user_name, :receive_status => self.receive_status, :content => self.content, :created_at => self.created_at}
  end
  
end