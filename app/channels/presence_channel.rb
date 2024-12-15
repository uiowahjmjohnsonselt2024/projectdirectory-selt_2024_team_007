#*********************************************************************
# This file was crafted using assistance from Generative AI Tools.
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November
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

      # Broadcast this user"s presence
      ActionCable.server.broadcast("presence_channel_#{game.id}", {
        user: @user.name,
        status: "online",
        health: game.game_users.find_by(user: @user)&.health,
        profile_image: @user.profile_image.attached? ? url_for(@user.profile_image) : ActionController::Base.helpers.asset_path("default_avatar.png")
      })

      # Broadcast all current active users to the new connection
      active_users.each do |user_id|
        user = User.find(user_id)
        transmit({
          user: user.name,
          status: "online",
          health: game.game_users.find_by(user: user)&.health,
          profile_image: user.profile_image.attached? ? url_for(user.profile_image) : ActionController::Base.helpers.asset_path("default_avatar.png")
        })
      end
    end
  end

    def unsubscribed
    game = Game.find_by(id: params[:game_id])
    if game && @user
      # Remove user from active users list
      $redis.srem("active_users_#{game.id}", @user.id)
      
      # Rotate turn if it was this user's turn
      if game.current_turn_user_id == @user.id
        active_user_ids = $redis.smembers("active_users_#{game.id}")
        active_users = User.where(id: active_user_ids)
        
        if active_users.present?
          next_user = active_users.first
          game.update(current_turn_user: next_user)
          
          # Broadcast turn update
          ActionCable.server.broadcast("presence_channel_#{game.id}", {
            action: 'update_turn',
            current_turn_user_id: next_user.id,
            current_turn_user_name: next_user.name
          })
        end
      end
  
      # Broadcast offline status
      ActionCable.server.broadcast("presence_channel_#{game.id}", {
        user: @user.name,
        status: "offline"
      })
    end
  end
end