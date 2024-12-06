class FriendsController < ApplicationController
  before_action :set_current_user
  before_action :set_user

  def index
    @friends = @user.friends + @user.inverse_friends
    @pending_friend_requests = @user.requesting_friends
    @sent_friend_requests = @user.pending_friends
  end

  def create
    friend = User.find_by(email: params[:friend_email].downcase)

    # Check if the user exists
    if friend.nil?
      flash[:alert] = "No user found with the email #{params[:friend_email]}."
      redirect_to friends_path
      return
    end

    # Prevent sending a request to oneself
    if friend == @user
      flash[:alert] = 'You cannot send a friend request to yourself.'
      redirect_to friends_path
      return
    end

    # Prevent duplicate friend requests or requests to existing friends
    if @user.friends.include?(friend) || @user.pending_friends.include?(friend)
      flash[:alert] = "#{friend.name} is already your friend or has a pending request."
      redirect_to friends_path
      return
    end

    # Create the friend request
    if @user.friendships.create(friend: friend)
      flash[:notice] = "Friend request sent to #{friend.name}!"
    else
      flash[:alert] = 'Unable to send friend request.'
    end

    redirect_to friends_path
  end


  def accept
    friendship = @user.received_friend_requests.find_by(user_id: params[:id])
    if friendship&.update(status: 'accepted')
      flash[:success] = 'Friend request accepted.'
    else
      flash[:error] = 'Unable to accept friend request.'
    end
    redirect_to friends_path
  end


  def reject
    friendship = @user.received_friend_requests.find_by(user_id: params[:id])
    if friendship&.destroy
      flash[:notice] = 'Friend request rejected.'
    else
      flash[:error] = 'Unable to reject friend request.'
    end
    redirect_to friends_path
  end

  def cancel
    friendship = @user.pending_friendships.find_by(friend_id: params[:id])
    if friendship&.destroy
      flash[:notice] = 'Friend request canceled.'
    else
      flash[:error] = 'Unable to cancel friend request.'
    end
    redirect_to friends_path
  end

  private

  def set_user
    @user = @current_user
  end
end
