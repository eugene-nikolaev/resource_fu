module ResourceFu::Resources::Exceptions
  class Base < ::StandardError
    def message
      custom_message || super
    end

    private

    def custom_message
    end
  end

  class AccessorNotDefined           < Base; end
  class AccessorActionAlreadyDefined < Base; end

  module Auth
    class Undefined < Base
      private
      def custom_message
        "Authorize block not defined" 
      end
    end

    class UndefinedScope < Base
      private
      def custom_message
        "Authorization scope was not found" 
      end
    end

    class AccessDenied < Base
      private
      def custom_message
        "Access denied" 
      end
    end

    class RuleNotFound < Base
      private
      def custom_message
        "Authorization rule was is not defined" 
      end
    end
  end
end
