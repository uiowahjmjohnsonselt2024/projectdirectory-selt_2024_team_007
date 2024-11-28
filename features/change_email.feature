Feature: Change Email
  As a user
  I want to change my email address
  So that I can update my contact information securely

  Background:
    Given the following user exists:
      | name      | email           | password    |
      | TestUser  | test@email.com  | password123 |
    And I am logged in as "test@email.com" with password "password123"
    And I am on the settings page

  Scenario: Open the Change Email modal
    When I click "Change Email" button
    Then I should see the "Change Email" modal

  Scenario: Attempt to change email with mismatched emails
    When I click the "Change Email" button
    And I fill in "Enter New Email" with "new_email@test.com"
    And I fill in "Re-enter New Email" with "different_email@test.com"
    And I fill in "Enter Current Password" with "password123"
    And I press "Save"
    Then I should see "Emails do not match."

  Scenario: Attempt to change email with incorrect password
    When I click the "Change Email" button
    And I fill in "Enter New Email" with "new_email@test.com"
    And I fill in "Re-enter New Email" with "new_email@test.com"
    And I fill in "Enter Current Password" with "wrongpassword"
    And I press "Save"
    Then I should see "Incorrect password. Please try again."

  Scenario: Successfully change email
    When I click the "Change Email" button
    And I fill in "Enter New Email" with "new_email@test.com"
    And I fill in "Re-enter New Email" with "new_email@test.com"
    And I fill in "Enter Current Password" with "password123"
    And I press "Save"
    Then I should see "Your email has been updated successfully."
    And the "Current Email" field should contain "new_email@test.com"
