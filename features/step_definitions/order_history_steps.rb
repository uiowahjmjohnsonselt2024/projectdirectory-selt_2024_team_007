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
When('I click Orders button') do
  find('#v-pills-billings-tab').click
end

Given("the user has made the following orders:") do |table|
  table.hashes.each do |order|
    purchased_at = case order["purchased_at"]
                   when "2 days ago" then Time.zone.now - 2.days
                   when "1 day ago" then Time.zone.now - 1.day
                   when "today" then Time.zone.now
                   else Time.zone.parse(order["purchased_at"]) # Fallback if a specific date is provided
                   end

    Order.create!(
      user: @current_user, # Replace with the variable holding your test user
      item_name: order["item_name"],
      item_type: order["item_type"],
      item_cost: order["item_cost"].to_i,
      purchased_at: purchased_at
    )
  end
end

Then("I should see the following orders:") do |table|
  table.hashes.each_with_index do |order, index|
    # Convert the purchased_at string into a Time object, similar to how you did before:
    displayed_time = case order["purchased_at"]
                     when "2 days ago" then Time.zone.now - 2.days
                     when "1 day ago" then Time.zone.now - 1.day
                     when "today" then Time.zone.now
                     else Time.zone.parse(order["purchased_at"])
                     end

    formatted_date = displayed_time.strftime('%b %d, %Y')

    within all("ul.list-group li.list-group-item")[index] do
      expect(page).to have_content(order["item_name"])
      expect(page).to have_content("Type: #{order['item_type']}")
      expect(page).to have_content("Cost: #{order['item_cost']} shards")
      expect(page).to have_content("Purchased At: #{formatted_date}")
    end
  end
end
