require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

describe IclProject do

  it "is valid with a title and description" do
    project = IclProject.new(:title => "Test Project", :description => "Sample Description")
    expect(project.valid?).to be_truthy
    expect(project.errors).to be_empty 
  end

  it "is invalid without a description" do
    project = IclProject.new(:title => "Test Project")
    expect(project.invalid?).to be_truthy
    expect(project.errors[:description]).to include("can't be blank")

  end

  it "is invalid without a title" do
    project = IclProject.new(:description => "Sample Description")
    expect(project.invalid?).to be_truthy
    expect(project.errors[:title]).to include("can't be blank")
  end

end
