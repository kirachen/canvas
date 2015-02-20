require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.describe IclProjectPortalController, :type => :controller do

  describe "GET show" do
    it "should display the page succesfully" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "CREATE create" do
  	it "should create a new project when the inputs are valid" 
  	it "should not create a new project when the inputs are invalid"

  end

end
