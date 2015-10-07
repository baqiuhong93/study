namespace :products do
  desc "This task does nothing"
  task :update_sale_num => :environment do
    UserAccount.where("status = 1 and created_at >= ?", DateTime.now-1.day).each do |account|
    	account.product.increment!(:sale_num, 1) unless account.product.nil?
    end
  end
end