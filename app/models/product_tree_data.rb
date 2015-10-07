class ProductTreeData < ActiveRecord::Base
  belongs_to :product
  belongs_to :product_tree_group
  attr_accessible :order_num, :product_tree_group_id

  has_paper_trail
end
