class ProductTree < ActiveRecord::Base
  has_ancestry {:cache_depth}
  
  after_initialize :default_values
  after_update :delete_cache
  
  attr_accessible :audition_path, :description, :name, :order_num, :pId, :node_type, :select_level, :record
  
  #has_many :product_tree_groups
  #has_many :products, :through => :product_tree_groups
  
  #has_many :knowledge_tree_groups
  #has_many :knowledge_trees, :through => :knowledge_tree_groups
  
  has_many :speaker_teachers, :as => :teacherable
  
  has_many :global_assets, :as => :assetable
  
  has_paper_trail

  def node?
    self.node_type == 1
  end
  
  def speaker_teachers_string
    self.speaker_teachers.collect! {|speaker_teacher| {"id" => speaker_teacher.teacher_id, "text" => speaker_teacher.teacher_name}}.to_s.gsub("=>", ":")
  end
  
  def global_assets_string
    if self.global_assets.nil?
      {}
    else
      self.global_assets.collect! {|global_asset| {"id" => global_asset.id, "text" => global_asset.data_file_name}}.to_s.gsub("=>", ":")
    end
  end
  
  def self.find_from_cache(id)
    APP_CACHE.fetch("product_trees_#{id}", 0) do
      ProductTree.where("id = ?", id).first
    end
  end
  
  def delete_cache
     APP_CACHE.delete("product_trees_#{self.id}")
  end
  
  private
  
  def default_values
    if self.new_record?
      self.order_num = 20 if self.order_num.nil?
      self.record = 0 if self.record.nil?
    end
  end
end
