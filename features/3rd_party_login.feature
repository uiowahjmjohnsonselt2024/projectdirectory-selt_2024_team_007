Feature: 3rd party (google) login
  As a user who is lazy to input all information,
  I want the ability to log in with my existing google account,
  So that I can quickly register and login without having password leaks.

  Scenario: User is half way entering the crediential, but they changed thier mind to do goolge login
    Given the following user exists:
      | name  | email            | password       |
      | Alice | alice@gmail.com  | password  |
    And I am on the login page
    When I fill in "email_field" with "alice@gmail.com"
    And I fill in "password_field" with "raaaaadompwd"
    And I press "Login with Google"
    Then I should be on "/landing"

  Scenario: User logs in as Hans
    Given I am logged in as "Hans"
    #Then I should be on "/landing"
    Then I should see "Welcome back, HansJohnson"

  Scenario: User logs in as Bob who does not have a name in the email account
    Given I am logged in as "Bob"
    #Then I should be on "/landing"
    Then I should see "Welcome back, UnknownUser"