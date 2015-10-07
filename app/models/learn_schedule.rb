class LearnSchedule
  include Mongoid::Document
  field :user_id, type: Integer
  field :user_name, type: String
  field :account_id, type: Integer
  field :product_id, type: Integer
  field :product_name, type: String
  field :knowledge_id, type: Integer
  field :knowledge_name, type:String
  field :knowledge_schedule, type: Hash
  field :created_at, type: DateTime
  field :updated_at, type: DateTime
  
  
  def schedule_sum
    _v = 0
    self.knowledge_schedule.each do |k,v|
      _v += v
    end
    _v
  end
end