module HelperMethods

  def login_as(user)
    Warden.test_mode!
    super
  end

  def login_with_form_as(user)
    click_link "Entra con tu cuenta de Agoraonrails"
    within("#agoraonrails-account") do
      fill_in :user_email, with: @user.email
      fill_in :user_password, with: @user.password
      click_button "Sign in"
    end
  end

  def login_with_tractis_as(user)
    stub_tractis_request
    get_tractis_callback(user.name, user.uid)
  end

  def register_with_tractis_as(name, dni)
    stub_tractis_request
    get_tractis_callback(name, dni)
  end
  
  def hack_attempt_to_reproduce_tractis_callback
    stub_tractis_not_authorized_request
    visit "/tractis_authentication?&I_try_to_hack_you=all_your_bases_are_belongs_to_us"
  end
  
  def get_tractis_callback(name, dni)
    visit "/tractis_authentication?&verification_code=f56dd2d18e490aa9246b993b95d8927e7147c91c&tractis%3Aattribute%3Adni=#{dni}&tractis%3Aattribute%3Aname=#{CGI.escape(name)}&token=f83a65a341853b28c5e0732209433488a0958d04&api_key=36ec6e54ef3e73f61339456abc9d05329afc62b2&tractis%3Aattribute%3Aissuer=DIRECCION+GENERAL+DE+LA+POLICIA"
  end

  def percentages_should_be(proposal, results)
    results.each do |key, value|
      page.should have_css(".#{key} .vote-percentage", :text => "#{value}%")
    end
  end
  
  def number_of_votes_should_be(proposal, votes)
    proposal.reload
    votes.each do |key, value|
      proposal.send(key).should == value
    end
  end
  
  def should_see_hot_proposals_in_this_order(titles)
    page.all(".proposals .proposal .proposal-title").map(&:text).should == titles
  end
  
  def stub_tractis_request
    stub_request(:post, "https://www.tractis.com/data_verification").
      to_return(:status => 200, :body => "", :headers => {})
  end
  
  def stub_tractis_not_authorized_request
    stub_request(:post, "https://www.tractis.com/data_verification").
      to_return(:status => 403, :body => "", :headers => {})
  end
end

RSpec.configuration.include HelperMethods, :type => :acceptance
