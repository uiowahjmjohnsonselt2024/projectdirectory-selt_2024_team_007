Feature: Settings Page
  As a user
  I want to navigate to the settings page from the dropdown menu

  Scenario: Navigating to the settings page
    Given I am on the landing page
    When I click "Settings" in the dropdown menu
    Then I should be redirected to the settings page
