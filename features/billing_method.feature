Feature: Billing Methods
  As a user
  I want to manage my billing methods
  So that I can use them for payments in the system

  Background:
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am logged in as "aliyo@email.com" with password "passwordiness"
    And the following billing methods exist:
      | Card Number       | Card Holder Name | Expiration Date |
      | 1234567812345678  | John Doe         | 12/25           |
    When I navigate to the landing page
    And I click the profile picture
    And I click "Settings" in the dropdown menu
    And I click Billings button
    Then I should see "Billing Information"

  Scenario: Add a new billing method
    When I click the "Add New Card" button
    Then I should see the "Add New Card" modal
    And I fill in the following fields for the billing method:
      | Card Number       | 1234567812345679     |
      | Card Holder Name  | John Doe            |
      | Expiration Date   | 2025-12-31          |
    And I click the "Add Card" button
    Then I should see "Success: Billing method added successfully."
    Then I should see "John Doe"
    Then I should see "**** **** **** 5679"
    Then I should see "Exp: 12/25"

  Scenario: Add an existing billing method
    When I click the "Add New Card" button
    Then I should see the "Add New Card" modal
    And I fill in the following fields for the billing method:
      | Card Number       | 1234567812345678     |
      | Card Holder Name  | John Doe            |
      | Expiration Date   | 2025-12-31          |
    And I click the "Add Card" button
    Then I should see "Danger: Card number Card already exists"
    Then I should see "John Doe"
    Then I should see "**** **** **** 5678"
    Then I should see "Exp: 12/25"

  Scenario: Edit an existing billing method
    When I click the "Edit" button for the card ending with "5678"
    Then I should see the "Edit Card" modal
    And I edit the following fields for the card ending in "5678":
      | Edit Card Number       | 1234567812345679     |
      | Edit Card Holder Name  | Jena Doe            |
      | Edit Expiration Date   | 2026-12-31          |
    And I click the "Update Card" button
    Then I should see "Success: Billing method updated successfully."
    Then I should see "Jena Doe"
    Then I should see "**** **** **** 5679"
    Then I should see "Exp: 12/26"

  Scenario: Delete an existing billing method
    When I click the "Edit" button for the card ending with "5678"
    Then I should see the "Edit Card" modal
    And I click the "Delete" button
    Then I should see "Success: Billing method deleted successfully."
