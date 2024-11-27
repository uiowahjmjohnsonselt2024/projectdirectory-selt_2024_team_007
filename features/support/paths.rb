# This file is used by web_steps.rb,
module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /^the home\s?page$/ then root_path
    when /^the sign-up page$/ then register_path
    when /^the login page$/ then login_path
    when /^the logout page$/ then logout_path
    when /^the register page$/ then register_path
    when /^the new password reset page$/ then new_password_reset_path
    when /^the edit password reset page for "(.*)"$/ then edit_password_reset_path($1)
    when /^the user profile page for "(.*)"$/ then user_path(User.find_by(name: $1))
    when /^the users page$/ then users_path
    when /^the sessions page$/ then sessions_path
    when /^the landing page$/ then landing_path

    # Everyone, put new mappings here as you need them. I based this off of the routes file/

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
