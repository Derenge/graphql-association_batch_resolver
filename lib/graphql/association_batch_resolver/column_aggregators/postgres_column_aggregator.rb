# frozen_string_literal: true

module GraphQL
  module AssociationBatchResolver
    module PostgresColumnAggregator
      def self.aggregate(expression)
        Arel::Nodes::NamedFunction.new('ARRAY_AGG', expression)
      end

      def self.deserialize(column)
        column
      end
    end
  end
end
