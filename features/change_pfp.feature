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