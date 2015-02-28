require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# Specs in this file have access to a helper object that includes
# the IclProjectPortalHelper. For example:
#
describe IclProjectPortalHelper do

    #include IclProjectPortalHelper

    describe "teacher actions" do
     it "should see that a user is a teacher in a course" do
       creator_user = User.create(:name => "Anandha")
       teacher_user = User.create(:name => "Susan")

       course = Course.create(:account_id => creator_user.id, :root_account_id => 1)
       enrollment = Enrollment.new()
       enrollment.user = teacher_user
       enrollment.course = course
       enrollment.type = "TeacherEnrollment"
       enrollment.save()
       expect(get_thought_courses(teacher_user)).not_to be_nil
    end

     it "should see that a user is not a teacher in any course"
   end
end


