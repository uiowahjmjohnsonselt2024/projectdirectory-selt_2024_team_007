Feature: Create a Game 
  As a player
  I want to create a game lobby
  So that I can play the game with other players

  Background:
    Given the following users exist and want to create a game:
      | name        | email            | password    |
      | ExampleUser | user@example.com | oldpassword |
      | TestUser    | test@example.com | testpass    |
    And I am logged in as "user@example.com" with password "oldpassword"
    And the user "user@example.com" has a shards balance of 1000
    And the user "test@example.com" has a shards balance of 1000


  Scenario: Creating a game with valid map size
  When I navigate to the landing page
  And I click on the "New Game" button
  And I fill in "game_name" with "Map Game"
  And I fill in "create_game_join_code" with "MAP123"
  And I fill in "game_map_size" with "6x6"
  And I submit the create game form
  Then I should see "Game was successfully created."
  When I navigate back to the landing page
  Then the game "Map Game" should be listed in my games

Scenario: Cannot create game with invalid map size format
  When I navigate to the landing page
  And I click on the "New Game" button
  And I fill in "game_name" with "Invalid Map"
  And I fill in "create_game_join_code" with "MAP456"
  And I fill in "game_map_size" with "6"
  And I submit the create game form
  Then I should see "Map size must be in the format 'NxM' (e.g., '6x6')"

Scenario: Cannot create game with map size too small
  When I navigate to the landing page
  And I click on the "New Game" button
  And I fill in "game_name" with "Small Map"
  And I fill in "create_game_join_code" with "MAP789"
  And I fill in "game_map_size" with "5x5"
  And I submit the create game form
  Then I should see "Map size must be at least 6x6"