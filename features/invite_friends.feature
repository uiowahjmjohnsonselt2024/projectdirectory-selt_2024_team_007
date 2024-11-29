Feature: Invite friends to a game
  As a user who has paid for a game,
  I want to be able to add up to 3 friends to join my game world,
  So that I can share my game experience with others and play collaboratively.

  Background:
    Given the following users exist:
      | name     | email             | password  |
      | Alice    | alice@example.com | password1 |
      | Bob      | bob@example.com   | password2 |
      | Charlie  | charlie@example.com | password3 |
      | David    | david@example.com | password4 |
      | Eve      | eve@example.com   | password5 |
    And I am logged in as "alice@example.com" with password "password1"
    And the user "alice@example.com" has a shards balance of 1000
    And I have the following friends:
      | email             |
      | bob@example.com   |
      | charlie@example.com |
      | david@example.com |
    When I navigate to the landing page
    And I click on the "New Game" button
    And I fill in "game_name" with "Alice's Adventure"
    And I fill in "create_game_join_code" with "ABC123"
    And I fill in "game_map_size" with "6x6"
    And I submit the create game form
    Then I should see "Game was successfully created."
    And I navigate back to the landing page
    Then the game "Alice's Adventure" should be listed in my games

  Scenario: Successfully invite 3 friends
    When I navigate to the landing page
    And I click on the "Add Friends" button for "Alice's Adventure"
    And I select the following friends to invite:
      | email               |
      | bob@example.com     |
      | charlie@example.com |
      | david@example.com   |
    And I press "Invite Friends"
    Then I should see "Friends successfully added to the game."

  Scenario: Prevent inviting non-friends
    When I navigate to the landing page
    And I click on the "Add Friends" button for "Alice's Adventure"
    Then I should not see "Eve"

  Scenario: Prevent inviting more than 3 friends
    When I have the following friends:
      | email             |
      | eve@example.com   |
    And I navigate to the landing page
    And I click on the "Add Friends" button for "Alice's Adventure"
    And I check "Bob"
    And I check "Charlie"
    And I check "David"
    And I check "Eve"
    And I press "Invite Friends"
    Then I should see "You can invite up to 3 friends."

  Scenario: Prevent inviting friends already in the game
    When I navigate to the landing page
    And I click on the "Add Friends" button for "Alice's Adventure"
    And I select the following friends to invite:
      | email               |
      | bob@example.com     |
    And I press "Invite Friends"
    When I navigate to the landing page
    And I click on the "Add Friends" button for "Alice's Adventure"
    Then I should not see "Bob"

  Scenario: Cannot add a 4th friend AFTER successfully inviting 3 friends
    Given I have the following friends:
      | email             |
      | eve@example.com   |
    When I navigate to the landing page
    And I click on the "Add Friends" button for "Alice's Adventure"
    And I select the following friends to invite:
      | email               |
      | bob@example.com     |
      | charlie@example.com |
      | david@example.com   |
    And I press "Invite Friends"
    Then I should see "Friends successfully added to the game."
    And I click on the "Add Friends" button for "Alice's Adventure"
    And I check "Eve"
    And I press "Invite Friends"
    Then I should see "Total players in a game cannot exceed 4."
