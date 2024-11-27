Feature: Join a Game 
    As a player
    I want to join an existing game lobby
    So that I can play the game with other players

  Background:
    Given the following users exist and want to create a game:
      | name        | email            | password    |
      | ExampleUser | user@example.com | oldpassword |
      | TestUser    | test@example.com | testpass    |
    And I am logged in as "user@example.com" with password "oldpassword"

  Scenario: Successfully joining an existing game lobby
    Given a game exists for joining with join code "A1B2C3"
    When I navigate to the landing page
    And I click on the "Join Game" button
    And I fill in "join_game_join_code" with "A1B2C3"
    And I submit the join game form
    Then I should see "You have successfully joined the game."
    When I navigate back to the landing page
    And the game "Mystic Quest" should be listed in my games

  Scenario: Attempting to join a game with an invalid join code
    Given a game exists for joining with join code "A1B2C3"
    When I navigate to the landing page
    And I click on the "Join Existing Game" button
    And I fill in "join_game_join_code" with "INVALID"
    And I submit the join game form
    Then I should see "Invalid join code."