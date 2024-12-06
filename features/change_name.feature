Feature: Change username
  As a user
  I want the ability change my username
  So that I can personalize my account and visually represent myself

  Background:
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "passwordiness"
    And I press "Sign in"
    Then I should be on "/landing"
    When I click the profile picture
    And I click "Settings" in the dropdown menu

  Scenario: Attempt to change with valid name
    Then I should be redirected to the settings page
    And I fill in "User Name" with "NewName"
    And I press "Save"
    Then I should see "Your name has been updated successfully."

  Scenario: Attempt to change with no name
    Then I should be redirected to the settings page
    And I fill in "User Name" with ""
    And I press "Save"
    Then I should see "Failed to update your name."
