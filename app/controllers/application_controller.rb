class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= begin
    User.find_or_create_by(session_id: session[:session_id])
  rescue ActiveRecord::RecordNotUnique #just in case race conditions
    retry
  end
end
