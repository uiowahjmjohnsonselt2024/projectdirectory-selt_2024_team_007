class PresenceChannel < ApplicationCable::Channel
  include Rails.application.routes.url_helpers
  def subscribed
    game = Game.find_by(id: params[:game_id])
    @user = User.find_by(id: params[:user_id])
    if game && @user
      stream_from "presence_channel_#{game.id}"
      
      # Add user to active users list
      active_users = $redis.smembers("active_users_#{game.id}") || []
      $redis.sadd("active_users_#{game.id}", @user.id)
      
      # Broadcast this user's presence
      ActionCable.server.broadcast("presence_channel_#{game.id}", {
        user: @user.name,
        status: 'online',
        health: game.game_users.find_by(user: @user)&.health,
        profile_image: @user.profile_image.attached? ? url_for(@user.profile_image) : ActionController::Base.helpers.asset_path('default_avatar.png')
      })
      
      # Broadcast all current active users to the new connection
      active_users.each do |user_id|
        user = User.find(user_id)
        transmit({
          user: user.name,
          status: 'online',
          health: game.game_users.find_by(user: user)&.health,
          profile_image: user.profile_image.attached? ? url_for(user.profile_image) : ActionController::Base.helpers.asset_path('default_avatar.png')
        })
      end
    end
  end

  def unsubscribed
    game = Game.find_by(id: params[:game_id])
    if game && @user
      # Remove user from active users list
      $redis.srem("active_users_#{game.id}", @user.id) 
      ActionCable.server.broadcast("presence_channel_#{game.id}", {
        user: @user.name,
        status: 'offline'
      })
    end
  end
end