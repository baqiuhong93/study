# encoding: utf-8
class Product < ActiveRecord::Base
  acts_as_taggable
  
  after_initialize :default_values
  after_update :delete_cache
  
  attr_accessible :code, :description, :keywords, :name, :origin_price, :product_type, :sale_price, :view_num, :product_type, :click_num, :img_path, :user_name, :status, :effect_type, :effect_str, :onlined_at, :created_at, :expired_at, :tag_list, :tree_group_data, :speaker_teachers, :product_text_attributes, :praise_num, :product_classworks, :exam_type_id, :type_id, :skxx_id, :sale, :mobile_description, :available, :exam_level_id, :sortrank
  
  
  
  belongs_to :product_text, :dependent => :destroy
  
  #has_many :product_tree_datas
  #has_many :product_tree_groups, :through => :product_tree_datas
  
  has_many :speaker_teachers, :as => :teacherable
  has_many :product_classworks
  
  has_paper_trail
  
  accepts_nested_attributes_for :product_text
  
  
  validates_uniqueness_of :code, :on => :create, :message => "编码必须唯一!"
  
  def speaker_teachers_string
    self.speaker_teachers.collect! {|speaker_teacher| {"id" => speaker_teacher.teacher_id, "text" => speaker_teacher.teacher_name}}.to_s.gsub("=>", ":")
  end
  
  def classworks_string
    self.product_classworks.collect! {|classwork| {"id" => classwork.classwork_id, "text" => classwork.classwork_name}}.to_s.gsub("=>", ":")
  end
  
  def tree_group_data_array
    if self.tree_group_data.nil? || self.tree_group_data == ''
      []
    else
      eval(self.tree_group_data.gsub(":", "=>"))
    end
  end
  
  def click_num_from_cache
    APP_CACHE.fetch("products_click_num_#{self.id}", 0) do
      self.click_num
    end
  end
  
  def incr_click_num
    _p_n = APP_CACHE.fetch("products_click_num_#{self.id}", 0) do
      self.click_num
    end
    _p_n = _p_n + 1
    APP_CACHE.set("products_click_num_#{self.id}", _p_n, 0)

    if _p_n%10 == 0
      self.update_attribute(:click_num, _p_n)
    end
    return _p_n
  end
  
  def praise_num_from_cache
    APP_CACHE.fetch("products_praise_num_#{self.id}", 0) do
      self.praise_num
    end
  end
  
  def incr_praise_num
    _p_n = APP_CACHE.fetch("products_praise_num_#{self.id}", 0) do
      self.praise_num
    end
    _p_n = _p_n + 1
    APP_CACHE.set("products_praise_num_#{self.id}", _p_n, 0)

    if _p_n%10 == 0
      self.update_attribute(:praise_num, _p_n)
    end
    return _p_n
  end
  
  def total_course_num
    _total_course_num = 0
    tree_group_data_array.each do |tgd|
      ptg = ProductTreeGroup.find_from_cache(tgd["id"])
      ptg.node_knowledge_tree_data_hash.each do |k,v|
        _total_course_num = _total_course_num + ptg.knowledges_course_sum(k) unless v.empty?
      end unless ptg.nil?
    end
    return _total_course_num
  end
  
  def self.product_type_hash
    {1 => "截止有效期", 2 => "有效天数"}
  end
  
  def effect_str_date
    if self.effect_type == 1
      self.effect_str + " 23:59:59"
    elsif self.effect_type == 2
      (DateTime.now + self.effect_str.to_i).strftime("%Y-%m-%d %H:%M:%S")
    else
      DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
  
  def tree_group_data_array
    if self.tree_group_data.nil? || self.tree_group_data == ''
      []
    else
      eval(self.tree_group_data.gsub(":", "=>"))
    end
  end
  
  
  def self.find_from_cache(id)
    APP_CACHE.fetch("products_#{id}", 0) do
      Product.where("id = ?", id).first
    end
  end
  
  def effect_str_datetime
    dates = self.effect_str.split("-")
    DateTime.new(dates[0].to_i,dates[1].to_i,dates[2].to_i,23,59,59)
  end
  
  def effective?
    if self.deleted
      return false
    else
      if self.effect_type == 1 && DateTime.now.to_i >= effect_str_datetime.to_i
        return false
      end
      return true
    end
  end

  def self.exam_type_id_hash
    {1 => "教师资格", 2 => "教师招考", 3 => "特岗教师"}
  end

  def self.exam_level_id_hash
    {1 => "中学", 2 => "小学", 3 => "幼儿园"}
  end

  def self.type_id_hash
    {1 => "笔试课程", 2 => "面试课程", 3 => "教材"}
  end

  def self.skxx_id_hash
    {1 => "面授课程", 2 => "网校课程", 3 => "教材"}
  end
  
  private
  
  def default_values
    if self.new_record?
      self.praise_num = 1 if self.praise_num.nil?
      self.sale = 1 if self.sale.nil?
      self.mobile_description = '' if self.mobile_description.nil?
      self.available = 0 if self.available.nil?
      self.exam_type_id = 0 if self.exam_type_id.nil?
      self.type_id = 0 if self.type_id.nil?
      self.skxx_id = 0 if self.skxx_id.nil?
      self.exam_level_id = '' if self.exam_level_id.nil?
      self.tree_group_data = '[]' if self.tree_group_data.nil?
      self.sortrank = 5 if self.sortrank.nil?
    end
  end
  
  def delete_cache
    APP_CACHE.delete("products_#{self.id}")
  end
end
