require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.describe IclProjectPortalController, :type => :controller do

  describe "GET show" do
    it "should display the page succesfully" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe "CREATE create" do

    it "should create a new project when the inputs are valid" #do
        #TODO isolate this behaviour
        
        #count_before = IclProject.count
        #@current_user.id = 1
        #post :create, {:title => 'Sample Project', :description =>'Sample Description'}
        #count_after = IclProject.count

        #count_after
        #assert_redirected_to :controller => "IclProjectPortalController", :action => "show"
        #expect(response).to redirect_to(:show)

    #end
    it "should not create a new project when the inputs are invalid"

  end

end
