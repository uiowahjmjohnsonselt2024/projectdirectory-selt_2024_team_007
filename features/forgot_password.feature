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
Feature: Forgot Password
  As a user,
  I want the ability to receive a password reset email by clicking a link,
  So that I can reset my password and regain access to my account if I forget my login credentials.

  Scenario: User requests a password reset
    Given the following users exist:
      | name         | email              | password    |
      | ExampleUser | user@example.com   | oldpassword |
    And I am on the login page
    When I follow "Forgot Password?"
    Then I should be on "/password_resets/new"
    When I fill in "email" with "user@example.com"
    And I press "Send Reset Email"
    Then I should be on "/login"
    Then I should see "Password reset email has been sent."

  Scenario: User provides a non-existent email
    Given I am on the login page
    When I follow "Forgot Password?"
    Then I should be on "/password_resets/new"
    When I fill in "email" with "nonexistent@example.com"
    And I press "Send Reset Email"
    Then I should see "Email address not found."
    And I should be on "/password_resets/new"