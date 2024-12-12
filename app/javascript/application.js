// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
// import consumer from "./channels/consumer";
// import "./chat";
//import "app/javascript/controllers"
// import "bootstrap";
// import "popper.js";
// import "channels"
import { application } from "controllers/application"
import { createConsumer } from "@rails/actioncable"

export default createConsumer()

export function openConnection() {
    return new WebSocket('ws://localhost:3000/cable');
}

document.addEventListener("DOMContentLoaded", () => {

    const gameElement = document.querySelector("[data-game-id]");
    if (!gameElement) return;
    const gameId = gameElement.dataset.gameId;  
  
    const connection = openConnection();
      connection.onopen = () => {
          const identifier = JSON.stringify({ channel: "ChatChannel", game_id: gameId });
          const subscribeMessage = { command: "subscribe", identifier: identifier };
          // const subscribeMessage = {"command": "subscribe", "identifier": "{\"channel\":\"ChatChannel\"}"};
          connection.send(JSON.stringify(subscribeMessage));
      };
    
    const responseField = document.getElementById("chatbot-response");
    if (!responseField) return;
  
  
    // if (!gameElement || !responseField) return;
  
    // const gameId = gameElement.dataset.gameId;
    console.log(`Connecting to ChatChannel for game ${gameId}`);
  
    consumer.subscriptions.create({ channel: "ChatChannel", game_id: gameId }, {
      connected() {
        console.log(`Connected to ChatChannel for game ${gameId}`);
      },
      disconnected() {
        console.log(`Disconnected from ChatChannel for game ${gameId}`);
      },
      received(data) {
        const newMessage = `
          <p><strong>${data.user}:</strong> ${data.message}</p>
          <p><em>GPT:</em> ${data.gpt_response}</p>
        `;
        responseField.innerHTML += newMessage;
        responseField.scrollTop = responseField.scrollHeight; // Auto-scroll to the bottom
      },
    });
  });
  

// document.addEventListener('DOMContentLoaded', () => {
//     // const connection = openConnection();
//     // connection.onopen = () => {
//     //     const subscribeMessage = {"command": "subscribe", "identifier": "{\"channel\":\"ChatChannel\"}"};
//     //     connection.send(JSON.stringify(subscribeMessage));
//     // };
// });

