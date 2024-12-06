Feature: Dropdown Menu
  As a user
  I want to see a dropdown menu when I click the profile picture

  Scenario: Clicking profile picture displays dropdown
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "passwordiness"
    And I press "Sign in"
    Then I should be on "/landing"
    When I click the profile picture
    Then I should see a dropdown menu with "Settings", "Friends", and "Log Out"
