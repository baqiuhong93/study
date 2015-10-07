class KnowledgeTreeGroup < ActiveRecord::Base
  attr_accessible :knowledge_tree_id, :order_num, :product_tree_id
  
  belongs_to :knowledge_tree
  belongs_to :product_tree

  has_paper_trail
end
