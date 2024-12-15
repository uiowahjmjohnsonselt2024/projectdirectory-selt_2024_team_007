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
Feature: 3rd party (google) login
  As a user who is lazy to input all information,
  I want the ability to log in with my existing google account,
  So that I can quickly register and login without having password leaks.

  Scenario: User is half way entering the crediential, but they changed thier mind to do goolge login
    Given the following user exists:
      | name  | email            | password       |
      | Alice | alice@gmail.com  | password  |
    And I am on the login page
    When I fill in "email_field" with "alice@gmail.com"
    And I fill in "password_field" with "raaaaadompwd"
    And I press "Login with Google"
    Then I should be on "/landing"

  Scenario: User logs in as Hans
    Given I am logged in as "Hans"
    #Then I should be on "/landing"
    Then I should see "Welcome back, HansJohnson"

  Scenario: User logs in as Bob who does not have a name in the email account
    Given I am logged in as "Bob"
    #Then I should be on "/landing"
    Then I should see "Welcome back, UnknownUser"