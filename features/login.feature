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
Feature: User Login

  As a user,
  I want the ability to log in to an existing account by clicking a button and entering my email and password,
  So that I can access the site and its features.

  Scenario: User logs in with correct credentials
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "passwordiness"
    And I press "Sign in"
    Then I should be on "/landing"

  Scenario: User logs in with incorrect credentials
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "wrong"
    And I press "Sign in"
    Then I should be on the login page
