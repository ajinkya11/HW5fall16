# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end


 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then /^(?:|I )should see "([^"]*)"$/ do |text|
    expect(page).to have_content(text)
 end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
    # Each returned movie will be a hash representing one row of the movies_table
    # The keys will be the table headers and the values will be the row contents.
    # Entries can be directly to the database with ActiveRecord methods
    # Add the necessary Active Record call(s) to populate the database.
  end
end

When /^I have opted to see movies rated: "(.*?)"$/ do |arg1|
  
  uncheck("ratings_G")
  uncheck("ratings_PG")
  uncheck("ratings_PG-13")
  uncheck("ratings_R")
  uncheck("ratings_NC-17")
  
  # HINT: use String#split to split up the rating_list, then
  # iterate over the ratings and check/uncheck the ratings
  # using the appropriate Capybara command(s)
  arg1.split(',').each do |rating|
    check 'ratings_' + rating.strip
  end
  
  
end

Then /^I should see only movies rated: "(.*?)"$/ do |arg1|
  rating_hash={}
  arg1.split(',').each do |rating|
    find('table').should have_css('td', :text => rating)
    rating_hash[rating]=1
  end
  Movie.all_ratings.each do |rating|
    if !rating_hash.has_key?(rating)
      find('table').should have_no_css('tb', :text => rating)
    end
  end  
end

Then /^I should see all of the movies$/ do
  rows=0
  find('table').find('tbody').all('tr').each do |tr|
    rows+=1
  end
  rows.should == Movie.all.count 
end

When /^I have sorted the movies by title$/ do
  click_on "title_header"
end

When /^I follow "(.*)"$/ do |link|
  click_link link
end

Then /^I should see "(.*?)" before "(.*?)"/ do |title1, title2|
  titles = values_from_column 'Title'

  expect(titles.index(title1)).to be < titles.index(title2), "expected '#{title1}' to appears before '#{title2}' in the page"
end

def values_from_column(column_name)
  position = "count(//thead/tr/th[text() = '#{column_name}']/preceding-sibling::th) + 1"

  all(:xpath, "//tbody/tr/td[#{position}]").map(&:text)
end


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
