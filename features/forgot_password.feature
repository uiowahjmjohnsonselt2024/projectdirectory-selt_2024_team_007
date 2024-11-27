Feature: Forgot Password
  As a user,
  I want the ability to receive a password reset email by clicking a link,
  So that I can reset my password and regain access to my account if I forget my login credentials.

  Scenario: User requests a password reset
    Given the following users exist:
      | name         | email              | password    |
      | ExampleUser | user@example.com   | oldpassword |
    And I am on the login page
    When I follow "Forgot Password?"
    Then I should be on "/password_resets/new"
    When I fill in "email" with "user@example.com"
    And I press "Send Reset Email"
    Then I should be on "/login"
    Then I should see "Password reset email has been sent."

  Scenario: User provides a non-existent email
    Given I am on the login page
    When I follow "Forgot Password?"
    Then I should be on "/password_resets/new"
    When I fill in "email" with "nonexistent@example.com"
    And I press "Send Reset Email"
    Then I should see "Email address not found."
    And I should be on "/password_resets/new"