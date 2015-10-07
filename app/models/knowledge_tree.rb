class KnowledgeTree < ActiveRecord::Base
  has_ancestry
  
  has_many :knowledge_tree_groups
  has_many :product_trees, :through => :knowledge_tree_groups
  
  after_initialize :default_values
  after_update :delete_cache

  has_paper_trail
  
  attr_accessible :audition_path, :course_num, :description, :listen_path, :name, :order_num, :pId, :node_type, :select_level, :record
  
  
  def video_id
    if !self.listen_path.html_safe.index('vid=').nil? && !self.listen_path.html_safe.index('&siteid').nil?
      self.listen_path.html_safe[self.listen_path.html_safe.index('vid=')+4...self.listen_path.html_safe.index('&siteid')]
    else
      ''
    end
  end
  
  def self.find_from_cache(id)
    APP_CACHE.fetch("knowledge_tree_#{id}", 0) do
      KnowledgeTree.where("id = ?", id).first
    end
  end
  
  private
  
  def delete_cache
    APP_CACHE.delete("knowledge_tree_#{self.id.to_s}") #删除知识点缓存
    ProductTreeGroup.where("node_knowledge_tree_data like '%#{self.id}%'").each do |product_tree_group|
      product_tree_group.node_knowledge_tree_data_hash.each do |k,v|
        APP_CACHE.delete("knowledges_course_sum_#{product_tree_group.id}_#{k}") if v.include?(self.id)
      end
    end
  end

  def default_values
    if self.new_record?
      self.course_num = 0 if self.course_num.nil?
      self.record = 1 if self.record.nil?
      self.select_level = 0 if self.select_level.nil?
    end
  end
end
