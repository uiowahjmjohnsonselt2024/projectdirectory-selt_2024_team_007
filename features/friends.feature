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
Feature: Friends Management
  As a user,
  I want to manage my friends,
  So that I can build and maintain my social network.

  Background:
    Given the following users exist:
      | name        | email               | password  |
      | JohnDoe    | john@example.com    | password1 |
      | JaneSmith  | jane@example.com    | password2 |
      | BobJohnson | bob@example.com     | password3 |
    And I am logged in as "john@example.com" with password "password1"

  Scenario: View Friends List
    Given I am on the friends page
    Then I should see "Your Friends:"
    And I should see "Friend Requests:"
    And I should see "Sent Friend Requests:"

  Scenario: Send a Friend Request
    Given I am on the friends page
    When I fill in "Friend's User Name: (Case sensitive)" with "JaneSmith"
    And I press "Send Friend Request"
    Then I should see "Friend request sent to JaneSmith!"
    And "JaneSmith" should be in "Sent Friend Requests"

  Scenario: Prevent Sending Friend Request to Nonexistent User
    Given I am on the friends page
    When I fill in "Friend's User Name: (Case sensitive)" with "nonexistentUser"
    And I press "Send Friend Request"
    Then I should see "No user found with the name nonexistentUser."

  Scenario: Prevent Sending Friend Request to Oneself
    Given I am on the friends page
    When I fill in "Friend's User Name: (Case sensitive)" with "JohnDoe"
    And I press "Send Friend Request"
    Then I should see "You cannot send a friend request to yourself."

  Scenario: Accept a Friend Request
    Given Jane Smith has sent me a friend request
    Given I am on the friends page
    Then I press "Accept"
    Then I should see "Friend request accepted."
    And "JaneSmith" should be in "Your Friends"

  Scenario: Reject a Friend Request
    Given Jane Smith has sent me a friend request
    Given I am on the friends page
    And I press "Decline"
    Then I should see "Friend request rejected."
    And "JaneSmith" should not be in "Your Friends"

  Scenario: Cancel a Sent Friend Request
    Given I am on the friends page
    When I fill in "Friend's User Name: (Case sensitive)" with "JaneSmith"
    And I press "Send Friend Request"
    Then I should see "Friend request sent to JaneSmith!"
    And "JaneSmith" should be in "Sent Friend Requests"
    Then I press "Refresh"
    And I press "Cancel"
    Then I should see "Friend request canceled."
    And "JaneSmith" should not be in "Sent Friend Requests"
