Feature: User Guide Page
  As a user
  I want a guide link that explains the game rules
  So that I can understand how to interact with the page and start playing confidently.

  Scenario: Navigating to the settings page
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "passwordiness"
    And I press "Sign in"
    Then I should be on "/landing"
    When I click the profile picture
    When I click "User Guide" in the dropdown menu
    Then I should be redirected to the User Guide page
