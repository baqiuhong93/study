class ProductClasswork < ActiveRecord::Base
  belongs_to :products
  belongs_to :classworks
  attr_accessible :product_id, :classwork_id, :classwork_name
end
