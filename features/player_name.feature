Feature: Displaying player profile name in the game

  As a player,
  I want my profile name to show in the game,
  So that other players know who I am.

  Background:
    Given the following users exist:
      | name        | email            | password    |
      | ExampleUser | user@example.com | oldpassword |
      | TestUser    | test@example.com | testpass    |
    And I am logged in as "user@example.com" with password "oldpassword"

  Scenario: Player's profile name is displayed in the game
    Given a game exists for joining with join code "A1B2C3"
    When I navigate to the landing page
    And I click on the "Join Game" button
    And I fill in "join_game_join_code" with "A1B2C3"
    And I submit the join game form
    Then I should see "You have successfully joined the game."
    # And my profile name "ExampleUser" should be displayed in the game lobby
    Given PENDING SCENARIO
