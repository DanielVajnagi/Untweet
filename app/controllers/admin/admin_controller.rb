module Admin
  class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin, except: [:stop_impersonating]

    def users
      @users = User.all
    end

    def tweets
      @tweets = Tweet.all
    end

    def impersonate
      user = User.find(params[:id])

      if user.superadmin_role?
        redirect_to admin_users_path, alert: t('notices.cannot_impersonate_superadmin')
      else
        impersonate_user(user)
        redirect_to root_path, notice: t('notices.impersonating', email: user.email)
      end
    end

    def stop_impersonating
      stop_impersonating_user
      redirect_to admin_users_path, notice: t('notices.stopped_impersonating')
    end

    def update_role
      user = User.find(params[:id])
      if current_user.is_superadmin? && user != current_user
        user.update(role: params[:role])
        redirect_to admin_users_path, notice: t('notices.role_updated', email: user.email, role: t("roles.#{user.role}"))
      else
        redirect_to admin_users_path, alert: t('notices.not_authorized')
      end
    end

    def ban
      user = User.find(params[:id])
      if current_user.is_admin? && user != current_user && !user.superadmin_role?
        user.update(banned: true)
        # If the banned user is currently logged in, sign them out
        if user == current_user
          sign_out user
          redirect_to new_user_session_path, alert: t('notices.user_banned')
        else
          redirect_to admin_users_path, notice: t('notices.user_banned')
        end
      else
        redirect_to admin_users_path, alert: t('notices.not_authorized')
      end
    end

    def unban
      user = User.find(params[:id])
      if current_user.is_admin? && user != current_user
        user.update(banned: false)
        redirect_to admin_users_path, notice: t('notices.user_unbanned', email: user.email)
      else
        redirect_to admin_users_path, alert: t('notices.not_authorized')
      end
    end

    private

    def require_admin
      unless current_user&.is_admin?
        redirect_to root_path, alert: t('notices.not_authorized')
      end
    end
  end
end