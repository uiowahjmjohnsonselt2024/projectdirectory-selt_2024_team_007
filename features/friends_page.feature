Feature: Friends Page
  As a user
  I want to navigate to the friends page from the dropdown menu

  Scenario: Navigating to the friends page
    Given I am on the index page
    When I click "Friends" in the dropdown menu
    Then I should be redirected to the friends page
