module ResourceFu::Resources::Extensions::Resourceable
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
end
