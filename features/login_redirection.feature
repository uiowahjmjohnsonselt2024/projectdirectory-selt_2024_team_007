Feature: Login Redirection
  As a logged-in user
  I want to be redirected to the index page after logging in

  Scenario: Logged-in user visits the site
    Given I am logged in
    When I visit the site
    Then I should be redirected to the index page
