module ResourceFu::Resources::Extensions
  module Configurable
    class Configuration
      attr_reader :actions

      def initialize
        @actions = []
      end
    end
  end
end
