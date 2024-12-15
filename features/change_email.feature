# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 4th 2024 to December 15, 2024.
# The AI Generated code was not sufficient or functional outright nor was it copied at face value.
# Using our knowledge of software engineering, ruby, rails, web development, and the constraints of
# our customer, SELT Team 007 (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, and Sheng Wang)
# used GAITs responsibly; verifying that each line made sense in the context of the app,
# conformed to the overall design, and was testable.
# We maintained a strict peer review process before any code changes were merged into the development
# or production branches. All code was tested with BDD and TDD tests as well as empirically tested
# with local run servers and Heroku deployments to ensure compatibility.
# *********************************************************************
Feature: Change Email
  As a user
  I want to change my email address
  So that I can update my contact information securely

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

  Scenario: Open the Change Email modal
    Then I should be redirected to the settings page
    When I click the "Change Email" button
    Then I should see the "Change Email" modal

  Scenario: Attempt to change email with mismatched emails
    Then I should be redirected to the settings page
    When I click the "Change Email" button
    And I fill in "Enter New Email" with "new_email@test.com"
    And I fill in "Re-enter New Email" with "different_email@test.com"
    And I fill in "Enter Current Password" with "passwordiness"
    And I press "Update Email"
    Then I should see "Emails do not match."

  Scenario: Attempt to change email with incorrect password
    When I click the "Change Email" button
    And I fill in "Enter New Email" with "new_email@test.com"
    And I fill in "Re-enter New Email" with "new_email@test.com"
    And I fill in "Enter Current Password" with "wrongpassword"
    And I press "Update Email"
    Then I should see "Incorrect password. Please try again."

  Scenario: Successfully change email
    When I click the "Change Email" button
    And I fill in "Enter New Email" with "new_email@test.com"
    And I fill in "Re-enter New Email" with "new_email@test.com"
    And I fill in "Enter Current Password" with "passwordiness"
    And I press "Update Email"
    Then I should see "Your email has been updated successfully."

