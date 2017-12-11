module Admin

  class UsersController < ControlPanelController

    def create
      begin
        user = User.create!(sanitized_params)
      rescue => e
        handle_error(e)
        @user = User.new
        render 'new'
      else
        flash['success'] = "User #{user.username} created."
        redirect_to admin_user_path(user)
      end
    end

    def destroy
      user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless user

      begin
        user.destroy!
      rescue => e
        handle_error(e)
        redirect_to admin_users_url
      else
        if user == current_user
          flash['success'] = 'Your account has been deleted.'
          sign_out
          redirect_to root_url
        else
          flash['success'] = "User #{user.username} deleted."
          redirect_to admin_users_url
        end
      end
    end

    def edit
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user
    end

    def index
      q = "%#{params[:q]}%"
      @users = User.where('users.username LIKE ?', q).order('username')
    end

    def new
      @user = User.new
    end

    def show
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user
    end

    def update
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user

      begin
        @user.update_attributes!(sanitized_params)
      rescue => e
        handle_error(e)
        render 'edit'
      else
        flash['success'] = "User #{@user.username} updated."
        redirect_to admin_user_path(@user)
      end
    end

    private

    def sanitized_params
      params.require(:user).permit(:username)
    end

  end

end