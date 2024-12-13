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
    And I click the Leave Game link inside the "Mystic Quest" game card
    Then I should see "You have successfully left the game."
    When I navigate back to the landing page
    Then the game "Mystic Quest" should not be listed in my games