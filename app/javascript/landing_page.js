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
document.addEventListener('DOMContentLoaded', () => {
  // Handle 'Create Game' button click
  const createGameButton = Array.from(document.querySelectorAll('button'))
    .find(btn => btn.textContent.trim() === 'Create Game');

  if (createGameButton) {
    createGameButton.addEventListener('click', () => {
      window.location.href = "/games/new";
    });
  } else {
    console.error("Create Game button not found.");
  }

  // Handle 'Join' buttons click
  const joinButtons = Array.from(document.querySelectorAll('button'))
    .filter(btn => btn.textContent.trim() === 'Join');

  joinButtons.forEach(button => {
    button.addEventListener('click', () => {
      const joinCode = button.getAttribute('data-join-code');
      const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

      // Create a form to submit the POST request
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '/games/join';

      // CSRF Token
      const csrfInput = document.createElement('input');
      csrfInput.type = 'hidden';
      csrfInput.name = 'authenticity_token';
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);

      // Join Code
      const joinCodeInput = document.createElement('input');
      joinCodeInput.type = 'hidden';
      joinCodeInput.name = 'join_code';
      joinCodeInput.value = joinCode;
      form.appendChild(joinCodeInput);

      document.body.appendChild(form);
      form.submit();
    });
  });
});