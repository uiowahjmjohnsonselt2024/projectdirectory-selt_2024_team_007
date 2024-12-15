// # *********************************************************************
// # This file was crafted using assistance from Generative AI Tools. 
// # Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 
// # 4th 2024 to December 15, 2024. The AI Generated code was not 
// # sufficient or functional outright nor was it copied at face value. 
// # Using our knowledge of software engineering, ruby, rails, web 
// # development, and the constraints of our customer, SELT Team 007 
// # (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, 
// # and Sheng Wang) used GAITs responsibly; verifying that each line made
// # sense in the context of the app, conformed to the overall design, 
// # and was testable. We maintained a strict peer review process before
// # any code changes were merged into the development or production 
// # branches. All code was tested with BDD and TDD tests as well as 
// # empirically tested with local run servers and Heroku deployments to
// # ensure compatibility.
// # *******************************************************************
// import consumer from "./consumer";

// document.addEventListener("DOMContentLoaded", () => {

//   const gameElement = document.querySelector("[data-game-id]");
//   if (!gameElement) return;
//   const gameId = gameElement.dataset.gameId;  

//   const connection = openConnection();
//     connection.onopen = () => {
//         const identifier = JSON.stringify({ channel: "ChatChannel", game_id: gameId });
//         const subscribeMessage = { command: "subscribe", identifier: identifier };
//         // const subscribeMessage = {"command": "subscribe", "identifier": "{\"channel\":\"ChatChannel\"}"};
//         connection.send(JSON.stringify(subscribeMessage));
//     };
  
//   const responseField = document.getElementById("chatbot-response");
//   if (!responseField) return;


//   // if (!gameElement || !responseField) return;

//   // const gameId = gameElement.dataset.gameId;
//   console.log(`Connecting to ChatChannel for game ${gameId}`);

//   consumer.subscriptions.create({ channel: "ChatChannel", game_id: gameId }, {
//     connected() {
//       console.log(`Connected to ChatChannel for game ${gameId}`);
//     },
//     disconnected() {
//       console.log(`Disconnected from ChatChannel for game ${gameId}`);
//     },
//     received(data) {
//       const newMessage = `
//         <p><strong>${data.user}:</strong> ${data.message}</p>
//         <p><em>GPT:</em> ${data.gpt_response}</p>
//       `;
//       responseField.innerHTML += newMessage;
//       responseField.scrollTop = responseField.scrollHeight; // Auto-scroll to the bottom
//     },
//   });
// });
