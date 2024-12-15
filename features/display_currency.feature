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
Feature: Display currency based on user country
  As a player,
  I want to be able to purchase in game content with any currency
  So that, I can purchase items from any country.

  Background:
    Given the following users exist:
      | name        | email               | password  |
      | JohnDoe    | john@example.com    | password1 |
      | JaneSmith  | jane@example.com    | password2 |
      | BobJohnson | bob@example.com     | password3 |
    And I am logged in as "john@example.com" with password "password1"

  @US
  Scenario: User from the US sees prices in USD
    Given I am a user from "US"
    When I visit the store items page
    Then I should see prices in "USD"

  @JP
  Scenario: User from Japan sees prices in JPY
    Given I am a user from "JP"
    When I visit the store items page
    Then I should see prices in "JPY"

  @Unknown
  Scenario: User from an unknown country sees prices in USD
    Given I am a user from "Unknown"
    When I visit the store items page
    Then I should see prices in "USD"
