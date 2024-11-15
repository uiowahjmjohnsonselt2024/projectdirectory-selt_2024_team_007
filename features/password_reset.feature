Feature: Password Reset Form
  As a user,
  I want the ability to submit a new password in a secure form after clicking a password reset link,
  So that I can successfully change my password and regain access to my account.

  Background:
    Given the following user exists:
      | name            | email            | password  |
      | Example User    | user@example.com | oldpassword |

  Scenario: User resets password using a valid reset link
    Given a valid password reset link exists for "user@example.com"
    When I visit the reset link
    And I enter "newpassword" in the password field
    And I enter "newpassword" in the password confirmation field
    And I click "Submit"
    Then I should see "Password has been reset."
    And I should be logged in
