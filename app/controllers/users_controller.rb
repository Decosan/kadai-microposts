class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:index,:show,:followings,:followers,:likes]
  
  def index
    @users=User.all.page(params[:page])
  end

  def new
    @user=User.new
  end

  def show
    @user=User.find(params[:id])
    @microposts = @user.microposts.order('created_at DESC').page(params[:page])
    counts(@user)
  end

  def create
    @user=User.new(user_params)
    if @user.save
      flash[:success]="userは正常に登録されました"
      redirect_to @user
    else 
      flash[:danger]="userは登録されませんでした"
      render :new
    end  
  end
  
  def followings
    @user = User.find(params[:id])
    @followings = @user.followings.page(params[:page])
    counts(@user)
  end
  
  def followers
    @user = User.find(params[:id])
    @followers = @user.followers.page(params[:page])
    counts(@user)
  end
  
  def likes
    params[:id] # user_id
    @microposts = User.liked_microposts_by(params[:id])
    # @microposts = current_user.feed_likes.order('created_at DESC').page(params[:page])
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
