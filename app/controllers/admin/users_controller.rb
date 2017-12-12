module Admin

  class UsersController < ControlPanelController

    ##
    # Responds to POST /admin/users
    #
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

    ##
    # Responds to DELETE /admin/users/:username
    #
    def destroy
      user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless user

      begin
        user.destroy!
      rescue => e
        handle_error(e)
        redirect_to admin_users_url
      else
        flash['success'] = "User #{user.username} deleted."
        redirect_to admin_users_url
      end
    end

    ##
    # Responds to GET /admin/users/:username/edit
    #
    def edit
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user
    end

    ##
    # Responds to GET /admin/users
    #
    def index
      q = "%#{params[:q]}%"
      @users = User.where('users.username LIKE ?', q).order('username')
    end

    ##
    # Responds to GET /admin/users/new
    #
    def new
      @user = User.new
    end

    ##
    # Responds to GET /admin/users/:username
    #
    def show
      @user = User.find_by_username params[:username]
      raise ActiveRecord::RecordNotFound unless @user
    end

    ##
    # Responds to PATCH /admin/users/:username
    #
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