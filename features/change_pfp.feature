Feature: Change Email
  As a user
  I want the ability change my profile image
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

  Scenario: Open the Change profile picture modal
    Then I should be redirected to the settings page
    When I click change profile picture
    Then I should see the "Upload Profile Picture" modal

  Scenario: Attempt to change pfp
    Then I should be redirected to the settings page
    When I click change profile picture
    And I attach "app/assets/images/logo.png" to "Choose an image":
    And I press "Upload"
    Then I should see "Profile image updated successfully."
    And I should see the new profile picture displayed