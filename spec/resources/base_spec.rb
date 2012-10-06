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
    describe_resource :read do |id|
      id
    end

    describe_resource :create do |params, options = 22|
      resource :default do
        options
      end
    end
  end

  let(:user_1) { User.new }
  let(:user_2) { User.new }

  subject { TestResource.new }

  it { should respond_to(:read) }
  it { should respond_to(:create) }
  its(:read) { should be_kind_of(ResourceFu::Resources::Resource) }
  its(:create) { should be_kind_of(ResourceFu::Resources::Resource) }

  describe "#resource assignment" do
    subject { TestResource.new.create(11) }
    its(:resources) { should_not be_empty }
    its(:resources) { should have(1).item }
    it "should have correct resource" do
      subject.resource(:default).should == 22
    end
  end
end
