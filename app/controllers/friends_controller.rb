# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
#   Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
# 4th 2024 to December 15, 2024. The AI Generated code was not
# sufficient or functional outright nor was it copied at face value.
# Using our knowledge of software engineering, ruby, rails, web
# development, and the constraints of our customer, SELT Team 007
# (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson,
# and Sheng Wang) used GAITs responsibly; verifying that each line made
# sense in the context of the app, conformed to the overall design,
# and was testable. We maintained a strict peer review process before
# any code changes were merged into the development or production
# branches. All code was tested with BDD and TDD tests as well as
# empirically tested with local run servers and Heroku deployments to
# ensure compatibility.
# *******************************************************************
class FriendsController < ApplicationController
  before_action :set_current_user
  before_action :set_user

  def index
    @friends = @user.friends + @user.inverse_friends
    @pending_friend_requests = @user.requesting_friends
    @sent_friend_requests = @user.pending_friends
  end

  def create
    friend = User.find_by(name: params[:friend_name])

    # Check if the user exists
    if friend.nil?
      flash[:alert] = "No user found with the name #{params[:friend_name]}."
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

  def unfriend
    friendship = @user.friendships.find_by(friend_id: params[:id]) ||
      @user.inverse_friendships.find_by(user_id: params[:id])

    if friendship&.destroy
      flash[:notice] = 'Friend removed successfully.'
    else
      flash[:error] = 'Unable to remove friend.'
    end

    redirect_to friends_path
  end

  private

  def set_user
    @user = @current_user
  end
end
