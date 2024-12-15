# *********************************************************************
# This file was crafted using assistance from Generative AI Tools.
# Open AI's ChatGPT o1, 4o, and 4o-mini models were used from November 4th 2024 to December 15, 2024.
# The AI Generated code was not sufficient or functional outright nor was it copied at face value.
# Using our knowledge of software engineering, ruby, rails, web development, and the constraints of
# our customer, SELT Team 007 (Cody Alison, Yusuf Halim, Ziad Hasabrabu, Bradley Johnson, and Sheng Wang)
# used GAITs responsibly; verifying that each line made sense in the context of the app,
# conformed to the overall design, and was testable.
# We maintained a strict peer review process before any code changes were merged into the development
# or production branches. All code was tested with BDD and TDD tests as well as empirically tested
# with local run servers and Heroku deployments to ensure compatibility.
# *********************************************************************
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
      | Card Number       | Card Holder Name | Expiration Date | CVV |
      | 1234567812345678  | John Doe         | 12/25           | 123 |
    When I navigate to the landing page
    And I click the profile picture
    And I click "Settings" in the dropdown menu
    And I click Billings button
    Then I should see "Billing Information"

  Scenario: Add a new billing method
    When I click the "Add New Card" button
    Then I should see the "Add New Card" modal
    And I fill in the following fields for the billing method:
      | Card Number       | 1234567812345679    |
      | Card Holder Name  | John Doe            |
      | Expiration Date   | 2025-12-31          |
      | CVV               | 5478                |
    And I click the "Add Card" button
    Then I should see "Success: Billing method added successfully."
    Then I should see "John Doe"
    Then I should see "**** **** **** 5679"
    Then I should see "Exp: 12/25"

  Scenario: Add an existing billing method
    When I click the "Add New Card" button
    Then I should see the "Add New Card" modal
    And I fill in the following fields for the billing method:
      | Card Number       | 1234567812345678    |
      | Card Holder Name  | John Doe            |
      | Expiration Date   | 2025-12-31          |
      | CVV               | 123                 |
    And I click the "Add Card" button
    Then I should see "Danger: Card number Card already exists"
    Then I should see "John Doe"
    Then I should see "**** **** **** 5678"
    Then I should see "Exp: 12/25"

  Scenario: Edit an existing billing method
    When I click the "Edit" button for the card ending with "5678"
    Then I should see the "Edit Card" modal
    And I edit the following fields for the card ending in "5678":
      | Edit Card Number       | 1234567812345679    |
      | Edit Card Holder Name  | Jena Doe            |
      | Edit Expiration Date   | 2026-12-31          |
      | Edit CVV               | 5478                |
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
