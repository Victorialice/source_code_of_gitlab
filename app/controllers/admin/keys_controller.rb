class Admin::KeysController < Admin::ApplicationController
  before_action :user, only: [:show, :destroy]

  def show
    @key = user.keys.find(params[:id])

    respond_to do |format|
      format.html
      format.js { head :ok }
    end
  end

  def destroy
    key = user.keys.find(params[:id])

    respond_to do |format|
      if key.destroy
        format.html { redirect_to keys_admin_user_path(user), status: 302, notice: 'User key was successfully removed.' }
      else
        format.html { redirect_to keys_admin_user_path(user), status: 302, alert: 'Failed to remove user key.' }
      end
    end
  end

  protected

  def user
    @user ||= User.find_by!(username: params[:user_id])
  end

  def key_params
    params.require(:user_id, :id)
  end
end
