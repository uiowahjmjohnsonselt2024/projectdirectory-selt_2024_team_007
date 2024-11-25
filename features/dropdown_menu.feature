Feature: Dropdown Menu
  As a user
  I want to see a dropdown menu when I click the profile picture

  Scenario: Clicking profile picture displays dropdown
    Given I am on the landing page
    When I click the profile picture
    Then I should see a dropdown menu with "Settings", "Friends", and "Log Out"
