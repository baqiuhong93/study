# encoding: utf-8
require 'net/http'
module ApplicationHelper
  
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end
  
  def format_date(datetime, default_val=nil)
    return  (default_val.nil? ? '' :  default_val) if datetime.nil?
    return datetime.strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def will_paginate(collection, options = {}) 
    options.merge!({ 
    :previous_label => '上一页', 
    :next_label => '下一页' 
    }) 
    super(collection, options) 
  end
  
  def get_cart(session, cookies)
    CartCookieUtil.get_cart(session,cookies)
  end
  
  def image_clip_path(image_path, clips_type, default_img='')
    FileUploadUtil.image_clip_path(image_path, clips_type,  default_img)
  end

  def cate_more_url(id)
    PUBLIC_CACHE.fetch("#{GlobalSettings.cate_more_key}_#{id}", 600) do
      if id.start_with?("#")
        Net::HTTP.get(GlobalSettings.cms_host, "/tools/cateUrl.jsp?uniqueCode=#{id[1..id.length]}").force_encoding('UTF-8')
      end
    end
  end
  
  def cms_part_page(id, next_id='')
    page_part_content = PUBLIC_CACHE.fetch("#{GlobalSettings.page_part_key}_#{id}", 600) do
      if id.start_with?("#")
        Net::HTTP.get(GlobalSettings.cms_host, "/util/fragment.jsp?id=#{id[1..id.length]}").force_encoding('UTF-8')
      else
        Net::HTTP.get(GlobalSettings.cms_host, "/util/fragment.jsp?id=#{id}").force_encoding('UTF-8')
      end
    end
    if page_part_content == '' && next_id != ''
      return cms_part_page(next_id)
    end
    return page_part_content.html_safe unless page_part_content.blank?
  end
  
  def cms_cate_list(code, length, type, titleLen='')
    if code.start_with?("#")
      page_part_content = PUBLIC_CACHE.fetch("#{GlobalSettings.cate_list_key}_#{code}", 600) do
        if type == 'li'
          Net::HTTP.get(GlobalSettings.cms_host, "/util/li.jsp?nodeIds=#{code[1..code.length]}&length=#{length}&titleLen=#{titleLen}").force_encoding('UTF-8')
        elsif type == 'dl'
          Net::HTTP.get(GlobalSettings.cms_host, "/util/dl.jsp?nodeIds=#{code[1..code.length]}&length=#{length}&titleLen=#{titleLen}").force_encoding('UTF-8')
        end
      end
    else
      page_part_content = PUBLIC_CACHE.fetch("#{GlobalSettings.cate_list_key}_#{code}", 600) do
        if type == 'li'
          Net::HTTP.get(GlobalSettings.cms_host, "/util/li.jsp?nodeIds=#{code}&perPage=#{length}").force_encoding('UTF-8')
        elsif type == 'dl'
          Net::HTTP.get(GlobalSettings.cms_host, "/util/dl.jsp?nodeIds=#{code}&perPage=#{length}").force_encoding('UTF-8')
        end
      end
    end
    page_part_content.html_safe unless page_part_content.nil?
  end
  
  def file_url(path)
    if path.nil?
      GlobalSettings.upload_view_url
    else
      GlobalSettings.upload_view_url + path
    end
  end
  
  def format_money(value)
    '%.2f' % value 
  end
  
  def product_path_domain(id)
    product = Product.find_from_cache(id)
    if Rails.env.production?
      GlobalSettings.product_url + "/" + product.code + ".html"
    else
      GlobalSettings.product_url + "/products/" + product.code
    end
  end
end
