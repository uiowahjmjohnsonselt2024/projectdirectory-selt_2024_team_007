Feature: User Sign Up

  As a user,
  I want the ability to create an account by clicking a button and entering my email and password,
  So that I can gain access to the site and its features.

  Scenario: User signs up with valid credentials
    Given I am on the sign-up page
    When I fill in "name_field" with "Alice"
    And I fill in "email_field" with "alice@example.com"
    And I fill in "password_field" with "passwordiness"
    And I fill in "password_confirmation_field" with "passwordiness"
    And I press "Create my account"
    Then I should be on the login page

  Scenario: User signs up with invalid credentials
    Given I am on the sign-up page
    When I fill in "name_field" with ""
    And I fill in "email_field" with "alice@example.com"
    And I fill in "password_field" with "passwordiness"
    And I fill in "password_confirmation_field" with "passwordiness"
    And I press "Create my account"
    Then I should be on the register page