class ProductTreeGroup < ActiveRecord::Base
  
  after_update :delete_cache
  
  attr_accessible :name, :product_tree_data, :order_num, :node_knowledge_tree_data
  
  
  #has_many :product_tree_datas
  #has_many :products, :through => :product_tree_datas

  has_paper_trail
  
  def product_tree_data_array
    if self.product_tree_data.nil? || self.product_tree_data == ''
      []
    else
      eval(self.product_tree_data.gsub(":", "=>").gsub("null", "0"))
    end
  end
  
  def node_knowledge_tree_data_hash
    if self.node_knowledge_tree_data.nil? || self.node_knowledge_tree_data == ''
      {}
    else
      eval(self.node_knowledge_tree_data.gsub(":", "=>"))
    end
  end
  
  def knowledges_course_sum(product_tree_id)
    APP_CACHE.fetch("knowledges_course_sum_#{self.id}_#{product_tree_id}", 0) do
      _knowledge_ids = self.node_knowledge_tree_data_hash[product_tree_id.to_s]
      if _knowledge_ids.nil? || _knowledge_ids.empty?
        _knowledge_ids = []
        self.product_tree_data_array.each do |ptd|
          _ids = self.node_knowledge_tree_data_hash[ptd["id"].to_s]
          _knowledge_ids = _knowledge_ids + _ids if ptd["pId"] == product_tree_id && !_ids.nil?
        end
        return 0 if _knowledge_ids.nil? || _knowledge_ids.empty?
        KnowledgeTree.where("id in (#{_knowledge_ids.uniq.join(',')})").sum("course_num")
      else
        KnowledgeTree.where("id in (#{_knowledge_ids.uniq.join(',')})").sum("course_num")
      end
      
    end
  end
  
  def self.find_from_cache(id)
    APP_CACHE.fetch("product_tree_groups_#{id}", 0) do
      ProductTreeGroup.where("id = ?", id).first
    end
  end
  
  
  def delete_cache
    APP_CACHE.delete("product_tree_groups_#{self.id}")
    self.node_knowledge_tree_data_hash.each do |k,v|
      APP_CACHE.delete("knowledges_course_sum_#{self.id}_#{k}")
    end
  end
end
