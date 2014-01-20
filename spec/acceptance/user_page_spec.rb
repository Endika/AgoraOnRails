  # coding: utf-8
require File.dirname(__FILE__) + '/acceptance_helper'

feature "User page", %q{
  In order to see compatibility with a user and maybe select him as my spokesman
  As a citizen
  I want to see the votes and opinions of a user
} do
  
  background do
    @proposal_1 = create_proposal(
               :title => "Ley Sinde", 
               :official_url => "http://congreso.es/sinde", 
               :proposal_type => "Proyecto de Ley")
               
    @proposal_2 = create_proposal(
               :title => "Legalización", 
               :official_url => "http://congreso.es/legalize", 
               :proposal_type => "Proposición de Ley")
              
    @proposal_3 = create_proposal(
               :title => "Wifi gratis", 
               :official_url => "http://congreso.es/wifi", 
               :proposal_type => "Proyecto de Ley")

    @bob  = create_user(:name => "BobMarley")
  end
  
  scenario "Voted proposals appear in the user page" do

    create_vote( :user  => @bob,
          :proposal     => @proposal_2, 
          :explanation  => "Purple haze all around",
          :value        => "si")
          
    create_vote( :user  => @bob,
          :proposal     => @proposal_3, 
          :explanation  => "Internet es un derecho fundamental de todos los humanos",
          :value        => "no")
    visit user_path(@bob)

    
    page.should_not have_css("#proposal_#{@proposal_1.id}")
    within(:css, "#proposal_#{@proposal_2.id}") do
      page.should have_content("Legalización")
      page.should have_content("A favor")
    end
    within(:css, "#proposal_#{@proposal_3.id}") do
      page.should have_content("Wifi gratis")
      page.should have_content("En contra")
    end
  end

  scenario "User can upload a picture" do
    login_as @bob
    visit user_path(@bob)
    click_link I18n.t(:edit_profile)
    attach_file("user[profile_picture]", "#{Rails.root}/spec/files/rails.png")
    click_button "Actualizar User"
    page.find('.profile_picture')['src'].should have_content 'rails.png' 
    #Would be nice to check the size no bigger than 300x300 here. 
  end
end