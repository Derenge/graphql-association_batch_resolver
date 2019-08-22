# frozen_string_literal: true

module GraphQL
  module AssociationBatchResolver
    module MysqlColumnAggregator
      def self.aggregate(expression)
        Arel::Nodes::NamedFunction.new('GROUP_CONCAT', expression)
      end

      def self.deserialize(column, type)
        column.split(',').map(&type.method(:deserialize))
      end
    end
  end
end
