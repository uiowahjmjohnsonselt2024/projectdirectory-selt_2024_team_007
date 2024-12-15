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
Feature: Shards and Store Navigation

  As a user who wants to enhance my game experience,
  I want the ability to click a button to go to the in-game purchases page,
  So that I can view and purchase items or upgrades that improve my gameplay.
  Background:
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "passwordiness"
    And I press "Sign in"
    Then I should be on "/landing"

  Scenario: View shard balance on the landing page
    Given I am on the landing page
    Then I should see "Shards: 0"

  @US
  Scenario: Navigate to the in-game purchases page from the landing page
    Given I am on the landing page
    When I click the store button
    Then I should be on "/store_items"

  Scenario: View shard balance on the settings page
    When I click the profile picture
    When I click "Friends" in the dropdown menu
    Then I should see "Shards: 0"

  @US
  Scenario: Navigate to the in-game purchases page from the settings page
    When I click the profile picture
    When I click "Friends" in the dropdown menu
    When I click the store button
    Then I should be on "/store_items"

  Scenario: Shards balance is updated and displayed correctly
    Given the user "aliyo@email.com" has a shards balance of 200
    When I navigate to the landing page
    Then I should see "Shards: 200"

  Scenario: Insufficient shards to create a game
    Given the user "aliyo@email.com" has a shards balance of 30
    When I submit the create game form
    Then I should see "Insufficient Shards Balance"
    And I should be on "/landing"