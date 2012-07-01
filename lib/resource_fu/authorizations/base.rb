module ResourceFu
  module Authorizations
    class Base

      # class TestAuth < Authorizations::Base
      #   # this object will always accept accessor
      #   # (for instance, user or admin instances) when it instantiates
      #
      #   def allowed_read?(resource)
      #     resource.user == accessor
      #   end
      # end

      attr_reader :accessor, :resource, :options

      def initialize(accessor, resource, options)
        @accessor, @resource, @options = accessor, resource, options
      end

      def allowed?(action)
        send("allowed_#{action}?")
      end
    end
  end
end
