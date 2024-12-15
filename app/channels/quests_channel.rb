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
