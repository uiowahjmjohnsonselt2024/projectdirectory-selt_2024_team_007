Feature: User Login

  As a user,
  I want the ability to log in to an existing account by clicking a button and entering my email and password,
  So that I can access the site and its features.

  Scenario: User logs in with correct credentials
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "passwordiness"
    And I press "Sign in"
    Then I should be on "/landing"

  Scenario: User logs in with incorrect credentials
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "wrong"
    And I press "Sign in"
    Then I should be on the login page
