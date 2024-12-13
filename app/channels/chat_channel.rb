class ChatChannel < ApplicationCable::Channel
  def subscribed
    logger.debug "Subscribed with params: #{params.inspect}"
    game = Game.find_by(id: (params[:game_id]))
    Rails.logger.info "Subscribed to game #{game.id}"
    stream_for game
  rescue ActiveRecord::RecordNotFound
    reject
    Rails.logger.info "Game #{params[:game_id]} not found"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
