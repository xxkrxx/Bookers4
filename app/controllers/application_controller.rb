class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def after_sign_in_path_for(resource)
    user_path(resource)
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email])
  end
end

   def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     name = conditions.delete(:name)
     where(conditions).where(["lower(name) = :value", { :value => name.downcase }]).first
   end