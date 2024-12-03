Feature: Display currency based on user country

  Scenario: User from the US sees prices in USD
    Given I am a user from "US"
    When I visit the store page
    Then I should see prices in "USD"

  Scenario: User from Japan sees prices in JPY
    Given I am a user from "JP"
    When I visit the store page
    Then I should see prices in "JPY"

  Scenario: User from an unknown country sees prices in USD
    Given I am a user from "Unknown"
    When I visit the store page
    Then I should see prices in "USD"
