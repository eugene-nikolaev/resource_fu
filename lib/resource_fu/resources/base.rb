# Base Service class
#
# Example:
#
# class TestService < ResourceFu::Services::Base
#   
#   authorize Post
#     can :update, :destroy do |post, user, options|
#       post.user == user
#     end
#
#     can :read do |post|
#       post.user == accessor || post.public?
#     end
#
#     can :edit do
#       resource.is_editable?(accessor)
#     end
#
#     can :manage, class_name: AuthPosts
#   end
#
#   action :read do |id, options = {}|
#     resource :post do
#       Post.find(id).tap do |post|
#         authorize!(:read, post)
#       end
#     end
#   end
#
#   action :create do |attributes|
#     resource do
#       Post.create(attrbutes)
#     end if can?(:create, Post)
#   end
# end
#
# service = TestService.new
# result = service.read
# result.resource(:post)


require_relative 'exceptions/exceptions'
require_relative 'extensions/configurable'
require_relative 'extensions/resourceable'
require_relative 'extensions/authorizable'

module ResourceFu::Resources
  class Base
    include Extensions::Authorizable

    class_attribute :configuration
    attr_accessor   :accessor
    attr_reader     :resource_options, :resource_result

    def initialize(options = {})
      @resource_options = options.dup
      @accessor         = @resource_options.delete(:as)
      @resource_result  = Extensions::Resourceable::Resource.new
    end

    class << self
      def action(name, &block)
        raise ArgumentError, "Block is required" if !block_given?
        self.configuration ||=  Extensions::Configurable::Configuration.new
        configuration.actions << name
        define_method name do |*args|
          instance_exec *args, &block
          resource_result
        end
      end

      def authorize(klass_or_name, &block)
        raise ArgumentError, "Block is required" unless block_given?
        self.configuration ||=  Extensions::Configurable::Configuration.new
        self.configuration.authorizations.add(klass_or_name, &block)
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

    # authorize!(:update, post)
    # authorize!(:read_all, Post)
    # authorize!(:read_all, :posts)
    # authorize!(:create, post, with: Authorizations::Post)
    def authorize!(action, resource_or_class_or_symbol, options = {})
      if options[:with].present?
        options[:with].new(
          accessor, resource_or_class_or_symbol, options
        ).allowed?(action)
      elsif configuration.authorizations.blank?
        raise Exceptions::Auth::Undefined
      elsif configuration.authorization(resource_or_class_or_symbol).blank?
        raise Exceptions::Auth::UndefinedScope
      elsif !authorized?(action, resource_or_class_or_symbol, options)
        raise Exceptions::Auth::AccessDenied
      end
    end    

    def authorized?(action, resource_or_class_or_symbol, options = {})
      configuration.authorization(resource_or_class_or_symbol).authorized?(
        action, resource_or_class_or_symbol, accessor, options
      )
    end
  end
end
