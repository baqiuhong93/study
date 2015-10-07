class GlobalAsset < ActiveRecord::Base
  belongs_to :user
  attr_accessible :assetable_id, :assetable_type, :data_content_type, :data_file_name, :data_file_size, :height, :user_name, :width, :data_file_url
end
