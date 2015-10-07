class Note < ActiveRecord::Base
  belongs_to :account
  belongs_to :product
  belongs_to :product_tree
  belongs_to :knowledge_tree
  belongs_to :user
  attr_accessible :account_id, :content, :product_id, :product_name, :user_name, :product_tree_id, :knowledge_tree_id, :knowledge_tree_name
end
