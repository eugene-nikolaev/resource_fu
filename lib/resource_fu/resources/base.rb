# Base Resource class
#
# Example:
#
# class TestResource < ResourceFu::Resources::Base
#
#   resource :read do |id, options = {}|
#     resource :post do
#       Post.find(id)
#     end
#   end
#
#   resource :create do |attributes|
#     resource do
#       Post.create(attrbutes)
#     end
#   end
# end
#
# resource = TestResource.new
# result = resource.read
# result.resource(:post)

module ResourceFu
  module Resources
    class Configuration
      attr_reader :actions

      def initialize
        @actions = []
      end
    end

    class Resource
      attr_reader :resources
      delegate    :count, :size, :each, :all, :map,
                  :inject, :reject, :collect, to: :resources

      def initialize
        @resources = {}
      end

      def resource(name)
        @resources[name]
      end

      def add(name, resource, options = {})
        @resources[name] = resource
        self
      end

      def remove(name)
        @resources.delete(name)
      end
    end

    class Base

      class_attribute :configuration
      attr_accessor   :accessor
      attr_reader     :resource_options, :resource_result

      def initialize(options = {})
        @resource_options = options.dup
        @accessor         = @resource_options.delete(:as)
        @resource_result  = Resource.new
      end

      class << self
        def describe_resource(name, &block)
          raise ArgumentError, "Block is required" if !block_given?
          self.configuration ||=  Configuration.new
          configuration.actions << name
          define_method name do |*args|
            instance_exec *args, &block
            resource_result
          end
        end
      end

      private

      def resource(name = :default, options = {}, &block)
        if block_given?
          resource_result.add(name, yield)
        else
          resource_result.resource(name)
        end
      end
    end
  end
end
