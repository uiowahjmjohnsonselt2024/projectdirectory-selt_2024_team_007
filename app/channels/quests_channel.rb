# app/channels/quests_channel.rb
class QuestsChannel < ApplicationCable::Channel
  def subscribed
    logger.debug "Subscribed to QuestsChannel with params: #{params.inspect}"
    game = Game.find_by(id: params[:game_id])
    if game
      logger.debug "Subscribed to game #{game.id} in QuestsChannel"
      stream_for game
    else
      logger.debug "Game #{params[:game_id]} not found in QuestsChannel"
      reject
    end
  end

  def unsubscribed
    logger.debug "Unsubscribed from QuestsChannel"
  end
end
