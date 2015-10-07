
class Ability
  include CanCan::Ability

  def initialize(user)
    
    #can 'read'.to_sym, 'Product'.constantize, 'product_type => 2'.to_sym
    
    if user.email == SYSTEM_ADMIN_USER_NAME
      can :manage, :all
    else
      user_visits = PUBLIC_CACHE.fetch("#{DEFINE_APP_ID}_user_visits_" + user.uid.to_s) do
          Net::HTTP.get(GlobalSettings.security_host, "/api/users/#{DEFINE_APP_ID}/#{user.uid}/permissions/#{user.security_key}", GlobalSettings.security_port).force_encoding('UTF-8')
      end
      
      user_visits = eval(user_visits.gsub(":","=>"))
      
      user_visits.each do |user_visit|
          can user_visit["action_name"].to_sym, user_visit["controller_name"].constantize if user_visit["rest"]
          can user_visit["action_name"].to_sym, user_visit["controller_name"].to_sym unless user_visit["rest"]
      end unless user_visits.nil?
      #UserVisit.where("app_id = ? and user_id = ?", DEFINE_APP_ID, user.uid).each do |user_visit|
      #  can user_visit.action_name.to_sym, user_visit.controller_name.constantize
      #end
      can :index, :home if user_visits.length > 0
    end
    
    #UserVisit.where("app_id = ? and user_id = ?", DEFINE_APP_ID, user.uid).each do |user_visit|
    #  can user_visit.action_name.to_sym, user_visit.controller_name.constantize
    #end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
