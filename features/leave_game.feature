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
Feature: Leave a Game
  As a player
  I want to leave an existing game lobby
  So that I can stop playing the game

  Background:
    Given the following users exist and want to create a game:
      | name        | email              | password    |
      | ExampleUser | user@example.com   | oldpassword |
      | TestUser    | test@example.com   | testpass    |
    And I am logged in as "user@example.com" with password "oldpassword"
    And a game exists with name "Mystic Quest" and owner "user@example.com"
    And "TestUser" has joined the game "Mystic Quest"

  Scenario: Successfully leaving an existing game lobby
    Given I am logged in as "test@example.com" with password "testpass"
    When I navigate to the landing page
    And I click the Leave Game button inside the "Mystic Quest" game card
    Then I should see "You have successfully left the game."
    When I navigate back to the landing page
    Then the game "Mystic Quest" should not be listed in my games