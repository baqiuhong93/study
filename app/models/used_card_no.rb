class UsedCardNo < ActiveRecord::Base
  belongs_to :card
  belongs_to :card_no
  belongs_to :user
  belongs_to :order

  has_paper_trail

  
  attr_accessible :card_name, :card_no_code, :order_id, :order_code, :user_name
end
