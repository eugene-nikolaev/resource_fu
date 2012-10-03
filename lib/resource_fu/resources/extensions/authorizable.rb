module ResourceFu::Resources
  module Extensions

    module Authorizable
      class Authorization
        attr_reader :actions
        
        def initialize(&block)
          raise ArgumentError, "Block not defined" unless block_given?
          @actions = {}
          instance_exec &block
        end

        class << self
          # authorization_scope(Post)    -> :posts
          # authorization_scope(:posts)  -> :posts
          # authorization_scope('posts') -> :posts
          def authorization_scope(resource_or_name)
            if resource_or_name.is_a?(Symbol)
              resource_or_name
            elsif resource_or_name.is_a?(String)
              resource_or_name.to_sym
            elsif resource_or_name.class == Class
              resource_or_name.to_s.downcase.pluralize.to_sym
            else
              resource_or_name.class.to_s.downcase.pluralize.to_sym
            end
          end
        end

        def authorized?(action, resource_or_class_or_symbol, accessor, options = {})
          action = action.to_sym
          raise Exceptions::Auth::RuleNotFound if actions.keys.exclude?(action)

          if actions[action].is_a?(Proc)
            actions[action].call(resource_or_class_or_symbol, accessor, options)
          else
            actions[action][:class_name].new(accessor, resource_or_class_or_symbol, options).allowed?(action)
          end
        end
        
        private

        def can(*actions, &block)
          options = actions.extract_options!
          if !options.blank?
            raise ArgumentError, "Authorization class not specified" if options[:class_name].blank?
            actions.each do |action|
              @actions[action.to_sym] = options
            end
          else
            raise ArgumentError, "Block not defined" unless block_given?
            actions.each do |action|
              @actions[action.to_sym] = block
            end
          end
        end

      end
    end

    module Configurable
      class Authorizations < Hash
        def add(class_or_name, &block)
          raise ArgumentError, "Block not defined" if !block_given?
          scope = ::ResourceFu::Resources::Extensions::Authorizable::Authorization.authorization_scope(class_or_name)
          self[scope] = ::ResourceFu::Resources::Extensions::Authorizable::Authorization.new(&block)
        end
      end
      
      class Configuration
        attr_reader :authorizations

        def authorizations
          @authorizations ||= Authorizations.new
        end

        def authorization(class_or_name)
          scope = ::ResourceFu::Resources::Extensions::Authorizable::Authorization.authorization_scope(class_or_name)
          authorizations[scope]
        end
      end
    end
    
  end
end
