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
Feature: View Orders in Settings Page
  As a User
  I want to have a viewable purchase history,
  So that I can see what I have purchased previously.

  Background:
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am logged in as "aliyo@email.com" with password "passwordiness"
    And the user has made the following orders:
      | item_name     | item_type       | item_cost | purchased_at        |
      | 10 Shards     | Shard Package   | 10        | 2 days ago          |
      | Teleport      | Store Item      | 2         | 1 day ago           |
      | Exclusive Item| Store Item      | 30        | today               |
    When I navigate to the landing page
    And I click the profile picture
    And I click "Settings" in the dropdown menu
    And I click Orders button

  Scenario: View orders in the Orders tab
    Then I should see "Here are your order details:"
    Then I should see the following orders:
      | item_name     | item_type       | item_cost | purchased_at |
      | Exclusive Item| Store Item      | 30        | today        |
      | Teleport      | Store Item      | 2         | 1 day ago    |
      | 10 Shards     | Shard Package   | 10        | 2 days ago   |