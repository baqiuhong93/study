class ApplicationController < ActionController::Base
  # reset captcha code after each request for security
  #after_filter :reset_last_captcha_code!
  before_filter :change_view, :if => proc {params[:change_view].present?}
  before_filter :set_html_view, :if => proc { is_tablet_device? }
  has_mobile_fu

  protect_from_forgery
  
  
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
      ## to avoid deprecation warnings with Rails 3.2.x (and incidentally using Ruby 1.9.3 hash syntax)
      ## this render call should be:
      # render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end
  
  def login_required
    if !current_user
      respond_to do |format|
        format.mobile  {
          session[LOGIN_SUC_CODE] = request.original_url if session[LOGIN_SUC_CODE].nil? && !request.xhr? && request.get?
          redirect_to '/auth/joshid'
        }
        format.html  {
          session[LOGIN_SUC_CODE] = request.original_url if session[LOGIN_SUC_CODE].nil? && !request.xhr? && request.get?
          redirect_to '/auth/joshid'
        }
        format.json {
          render :json => { 'error' => 'Access Denied' }.to_json
        }
      end
    else
      cache_key = session["ajax_key_#{current_user.uid.to_s}".to_sym]
      cookie_key = current_user.ajax_key
      if !cache_key.nil? && !cookie_key.nil?
        if cache_key != cookie_key
          if session[:force_sign_out].nil?
            session[:force_sign_out] = true
            respond_to do |format|
              format.mobile  {
                redirect_to "http://m.xredu.com/mobile/tuichu"
              }
              format.html  {
                redirect_to "http://www.xredu.com/tuichu.html"
              }
              format.json {
                render :json => { 'error' => 'System error' }.to_json
              }
            end
          else
            session[:force_sign_out] = nil
            current_user.ajax_key = cache_key
            current_user.save
          end
        end
      else
        respond_to do |format|
          format.mobile  {
            redirect_to  "http://m.xredu.com/mobile/tuichu"
          }
          format.html  {
            redirect_to  "http://www.xredu.com/tuichu.html"
          }
          format.json {
            session = nil
            render :json => { 'error' => 'System error' }.to_json
          }
        end
      end
    end
  end

  def current_user
    return nil unless session[:user_id]
    @current_user ||= User.find_from_cache(session[:user_id]['uid'])
  end
  
  
  def paper_trail_enabled_for_controller
    request.path.start_with?("/admin/")
  end
  
  def user_for_paper_trail
    current_user ? current_user.name : 'System'
  end

  def set_layout_dync
    session[:mobile_view] ? "mobile_front" : "front"
  end

  def change_view
    if session[:mobile_view]
      session[:mobile_view] = false
    else
      session[:mobile_view] = true
    end
  end

  def set_html_view
    session[:tablet_view] = false
  end
end
