# encoding: utf-8

class UserSessionsController < ApplicationController
  before_filter :login_required, :only => [ :destroy, :check_key ]

  respond_to :html

  # omniauth callback method
  def create
    omniauth = env['omniauth.auth']
    logger.debug "+++ #{omniauth}"

    user = User.find_by_uid(omniauth['uid'])
    if not user
      # New user registration
      user = User.new(:uid => omniauth['uid'])
    end
    user.email = omniauth['info']['email']    
    user.name = omniauth['info']['name']
    user.salt = omniauth['info']['salt']
    user.ajax_key = Digest::MD5.hexdigest(omniauth['uid'] + "_" + omniauth['info']['salt'] + "_" + Time.now.to_s)
    user.save
    session["ajax_key_#{omniauth['uid']}".to_sym] = user.ajax_key
    #p omniauth

    # Currently storing all the info
    session[:user_id] = omniauth

    flash[:notice] = "登录成功."
    login_suc_url = session[LOGIN_SUC_CODE] || root_path
    session[LOGIN_SUC_CODE] = nil
    redirect_to login_suc_url
  end

  # Omniauth failure callback
  def failure
    flash[:notice] = params[:message]
  end

  # logout - Clear our rack session BUT essentially redirect to the provider
  # to clean up the Devise session from there too !
  def destroy
    session[:user_id] = nil

    flash[:notice] = '退出成功.'
    redirect_to "#{CUSTOM_PROVIDER_URL}/users/sign_out"
  end

  def check_key
    respond_to do |format|
      format.html  {
        redirect_to "#{GlobalSettings.provider_url}/users/sign_out"
      }
      format.json {
        render :json => { 'success' => 'true' }.to_json
      }
    end
  end
end
