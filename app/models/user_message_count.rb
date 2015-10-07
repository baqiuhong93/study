class UserMessageCount
  include Mongoid::Document
  field :user_id, type: Integer
  field :user_name, type: String
  field :private_count, type: Integer
  
  field :system_count, type: Integer
  
  field :study_count, type: Integer
  
  field :updated_at, type: DateTime
  
  def self.inc_private_message(user_id)
    user_message = UserMessageCount.where(:user_id => user_id).first
    if user_message.nil?
      user = User.find_from_cache(user_id)
      if !user.nil?
        user_message = UserMessageCount.new
        user_message.user_id = user.uid
        user_message.user_name = user.name
        user_message.private_count = 1
        user_message.system_count = 0
        user_message.study_count = 0
        user_message.updated_at = DateTime.now
        user_message.save
      end
    else
      user_message.inc(:private_count, 1)
      user_message.updated_at = DateTime.now
      user_message.save
    end
  end
  
  def self.inc_system_message(user_id)
    user_message = UserMessageCount.where(:user_id => user_id).first
    if user_message.nil?
      user = User.find_from_cache(user_id)
      if !user.nil?
        user_message = UserMessageCount.new
        user_message.user_id = user.uid
        user_message.user_name = user.name
        user_message.private_count = 0
        user_message.system_count = 1
        user_message.study_count = 0
        user_message.updated_at = DateTime.now
        user_message.save
      end
    else
      user_message.inc(:system_count, 1)
      user_message.updated_at = DateTime.now
      user_message.save
    end
  end
  
  def self.inc_study_message(user_id)
    user_message = UserMessageCount.where(:user_id => user_id).first
    if user_message.nil?
      user = User.find_from_cache(user_id)
      if !user.nil?
        user_message = UserMessageCount.new
        user_message.user_id = user.uid
        user_message.user_name = user.name
        user_message.private_count = 0
        user_message.system_count = 0
        user_message.study_count = 1
        user_message.updated_at = DateTime.now
        user_message.save
      end
    else
      user_message.inc(:study_count, 1)
      user_message.updated_at = DateTime.now
      user_message.save
    end
  end
  
end