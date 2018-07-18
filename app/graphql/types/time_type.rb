module Types
  class TimeType < BaseScalar
    graphql_name 'Time'
    description 'Time represented in ISO 8601'

    def self.coerce_input(value, ctx)
      Time.parse(value)
    end

    def self.coerce_result(value, ctx)
      value.iso8601
    end
  end
end
