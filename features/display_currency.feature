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
