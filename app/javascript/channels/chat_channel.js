import consumer from "./consumer";

document.addEventListener("DOMContentLoaded", () => {
  const gameElement = document.querySelector("[data-game-id]");
  const responseField = document.getElementById("chatbot-response");

  if (!gameElement || !responseField) return;

  const gameId = gameElement.dataset.gameId;

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
