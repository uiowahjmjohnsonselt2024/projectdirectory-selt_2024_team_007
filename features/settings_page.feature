Feature: Settings Page
  As a user
  I want to navigate to the settings page from the dropdown menu

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
    When I click "Settings" in the dropdown menu
    Then I should be redirected to the settings page
