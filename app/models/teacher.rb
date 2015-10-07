# encoding: utf-8
class Teacher < ActiveRecord::Base
  after_initialize :default_values
  attr_accessible :description, :img_path, :name, :recommend, :subject_first, :subject_second, :ttype, :code, :deleted, :sortrank

  has_paper_trail
  
  validates_presence_of :code, :on => :create, :message => "编码不能为空"
  validates_uniqueness_of :code, :on => :create, :message => "编码必须唯一"
  
  def self.subject_first_array
    [{:id => 100, :text => "教师资格"}, {:id => 200, :text => "教师招聘"}, {:id => 300, :text => "专业知识"}, {:id => 400, :text => "说课面试"}]
  end
  
  def self.subject_second_hash
    {100 => [{:id => 101, :text => "教育学"}, {:id => 102, :text => "教育心理学"}, {:id => 103, :text => "综合素质"}, {:id => 104, :text => "教育知识与能力"}], 200 => [{:id => 201, :text => "教育学"}, {:id => 202, :text => "心理学"}, {:id => 203, :text => "教育心理学"}, {:id => 204, :text => "职业道德"}, {:id => 205, :text => "新课改"}], 300 => [{:id => 301, :text => "语文"}, {:id => 302, :text => "数学"}, {:id => 303, :text => "英语"}, {:id => 304, :text => "物理"}, {:id => 305, :text => "化学"}, {:id => 306, :text => "生物"}, {:id => 307, :text => "音乐"}, {:id => 308, :text => "体育"}, {:id => 309, :text => "美术"}, {:id => 310, :text => "政治"}, {:id => 311, :text => "历史"}, {:id => 312, :text => "地理"}], 400 => [{:id => 401, :text => "中学"}, {:id => 402, :text => "小学"}, {:id => 403, :text => "幼教"}, {:id => 404, :text => "教师招聘考试"}]}
  end
  
  def self.ttype_hash
    {"1" => "授课老师", "2" => "咨询老师"}
  end
  
  
  def description_more
    if self.description.nil?
      ''
    elsif self.description.length > 22
      self.description[0..21]+'...'
    else
      self.description
    end
  end
  
  def recommend_text
    if self.recommend
      '是'
    else
      '否'
    end
  end
  
  def deleted_text
    if self.deleted
      '是'
    else
      '否'
    end
  end
  
  private
  
  def default_values
    if self.new_record?
      self.deleted = 0 if self.deleted.nil?
      self.sortrank = 10 if self.sortrank.nil?
    end
  end
end
