When(/^I go to the homepage$/) do
  visit(HomePage)
end

Then(/^I should see the welcome message$/) do
  expect(on(HomePage).greeting).to eq("ACOB Todo App")
end