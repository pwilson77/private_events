class ApplicationController < ActionController::Base
    helper_method :current_user, :logged_in_user
    
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    def log_in(user)
        session[:user_id] = user.id
    end


    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    def current_user?(user)
        user == current_user()
    end

    def logged_in?
      not current_user.nil?
    end

    def current_user
        if (user_id = session[:user_id]) #its really an equal sign
          @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
          #raise       # The tests still pass, so this branch is currently untested.
          user = User.find_by(id: user_id)
          if user && user.authenticated?(:remember, cookies[:remember_token])
            log_in(user)
            @current_user = user
          end
        end
    end
    
    def current_user=(user)
        @current_user = user
    end

    def signout
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end

    def logged_in_user
        unless logged_in?
          flash[:danger] = "Please log in."
          redirect_to signin_url
        end
    end

end
