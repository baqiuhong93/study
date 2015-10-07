# encoding: utf-8
class Admin::HomeController < ApplicationController
  before_filter :login_required
  authorize_resource :class => false
  layout "admin"
  
  def index
    
  end
  
end