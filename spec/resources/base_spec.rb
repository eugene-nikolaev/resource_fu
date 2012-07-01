require 'spec_helper'

describe ResourceFu::Resources::Base do

  class User
  end

  class Resource
    attr_reader :user
    def initialize(user)
      @user = user
    end
  end

  class TestResource < ResourceFu::Resources::Base
    authorize Resource do
      can :create do |resource, user, options|
        resource.user == user
      end

      can :destroy do |resource, user, options|
        resource.user == user
      end
    end

    action :read do |id|
      id
    end

    action :create do |params, options = 22|
      resource :default do
        options
      end
    end

    action :destroy do |user|
      authorize!(:destroy, Resource.new(user))
    end
  end

  let(:user_1) { User.new }
  let(:user_2) { User.new }

  subject { TestResource.new }

  it { should respond_to(:read) }
  it { should respond_to(:create) }
  its(:read) { should be_kind_of(ResourceFu::Resources::Extensions::Resourceable::Resource) }
  its(:create) { should be_kind_of(ResourceFu::Resources::Extensions::Resourceable::Resource) }

  describe "#resource assignment" do
    subject { TestResource.new.create(11) }
    its(:resources) { should_not be_empty }
    its(:resources) { should have(1).item }
    it "should have correct resource" do
      subject.resource(:default).should == 22
    end
  end

  describe "Authorization" do
    subject { TestResource.new(as: user_1) }

    it "should raise authorization error for unauthorized user" do
      lambda {
        subject.destroy(user_2)
      }.should raise_error
    end

    it "should raise authorization error for authorized user" do
      lambda {
        subject.destroy(user_1)
      }.should_not raise_error
    end
    
  end
end
