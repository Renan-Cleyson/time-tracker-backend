# frozen_string_literal: true

# CRUD operations on user model controller.
class UsersController < ApplicationController
  skip_before_action :login_required, only: %i[create login]

  def create
    @user = User.new(user_params)
    if @user.save
      render :show, status: :created
    else
      render json: @user.errors.messages, status: :unprocessable_entity
    end
  end

  def show; end

  def update
    @user.update(user_params)
  end

  def destroy
    @user.destroy
  end

  def login
    @user = User.find_by(username: params[:username])
    if @user&.authenticate(params[:password])
      @token = JsonWebToken.encode({ user_id: @user.id })
      @user.update(authentication_token: @token)
      render :login
    else
      render json: { message: "Username or password don't match" },
             status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:username,
                                 :full_name,
                                 :email,
                                 :password,
                                 :password_confirmation)
  end
end
