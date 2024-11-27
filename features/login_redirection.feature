Feature: Login Redirection
  As a logged-in user
  I want to be redirected to the index page after logging in

  Scenario: Logged-in user visits the site
    Given the following user exists:
      | name  | email            | password       |
      | Alice | aliyo@email.com  | passwordiness  |
    And I am on the login page
    When I fill in "email_field" with "aliyo@email.com"
    And I fill in "password_field" with "passwordiness"
    And I press "Sign in"
    Then I should be on "/landing"
    When I visit the site
    Then I should be on "/"
    And I should see "Games:"
    And I should see "Welcome back, Alice!"
