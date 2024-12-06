// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
// import "app/javascript/controllers"
// import "bootstrap";
// import "popper.js";
// import "./channels"

function openConnection() {
    return new WebSocket('ws://localhost:3000/cable');
}

document.addEventListener('DOMContentLoaded', () => {
    const connection = openConnection();
    connection.onopen = () => {
        const subscribeMessage = {"command": "subscribe", "identifier": "{\"channel\":\"GameChannel\"}"};
        connection.send(JSON.stringify(subscribeMessage));
    };
});