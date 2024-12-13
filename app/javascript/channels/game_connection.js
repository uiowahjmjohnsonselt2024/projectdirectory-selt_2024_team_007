// app/javascript/channels/game_connection.js
export function initializeGameConnection() {
    const connection = new WebSocket('ws://localhost:3000/cable');
    
    connection.onopen = () => {
      const subscribeMessage = {
        "command": "subscribe", 
        "identifier": "{\"channel\":\"GameChannel\"}"
      };
      connection.send(JSON.stringify(subscribeMessage));
    };
  
    return connection;
  }