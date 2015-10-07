#encoding: utf-8

class ImagesController < ApplicationController
  
  def clips
    
    if GlobalSettings[params[:module].to_sym].nil?
        send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
        return
    end
    
    image_config_hash = GlobalSettings[params[:module].to_sym]
    if image_config_hash.nil? || image_config_hash[params[:config]].nil?
      send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
      return
    end
    
    image_full_path = [GlobalSettings.upload_path, params[:module], params[:year], params[:month], params[:day], params[:imagename]].join('/')
    
    if !File.exists?(image_full_path)
        send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
        return
    end
    module_config_hash = GlobalSettings[params[:module].to_sym][params[:config]]
    
    g_image_dir = [GlobalSettings.upload_path, params[:module], params[:year], params[:month], params[:day], params[:config]].join('/') + '/'
    
    FileUtils.mkpath g_image_dir unless File.exists?(g_image_dir)
    
    original = Magick::Image.read(image_full_path).first
    if module_config_hash['height'].nil?
      height = module_config_hash['width'].to_f/original.columns.to_f*original.rows
    else
      height = module_config_hash['height']
    end
    original = original.resize(module_config_hash['width'], height)
    original.write(g_image_dir+params[:imagename])
    send_data(original.to_blob, :type => original.mime_type.strip, :disposition => "inline")
    return
  end
end
