module ContainerRegistry
  class Config
    attr_reader :tag, :blob, :data

    def initialize(tag, blob)
      @tag, @blob = tag, blob
      @data = JSON.parse(blob.data)
    end

    def [](key)
      return unless data

      data[key]
    end
  end
end
