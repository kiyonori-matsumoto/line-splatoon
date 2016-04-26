class UsersController < ApplicationController
  def show
    @user = User.find_by(line_uid: params[:line_uid])
  end

  def edit
    @user = User.find_by(line_uid: params[:line_uid])
  end

  def update
    @user = User.find_by(line_uid: params[:line_uid])
    if @user.update_attributes(user_params)
      render 'show'
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:line_name, :stat_ink_id)
  end
end
