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
    Given the user "aliyo@email.com" has a shards balance of 4
    When I submit the create game form
    Then I should see "Insufficient Shards Balance"
    And I should be on "/landing"