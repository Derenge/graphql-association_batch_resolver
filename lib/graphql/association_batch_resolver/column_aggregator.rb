# frozen_string_literal: true

require_relative 'column_aggregators/mysql_column_aggregator'
require_relative 'column_aggregators/postgres_column_aggregator'

module GraphQL
  module AssociationBatchResolver
    module ColumnAggregator
      def self.aggregate(expression)
        adapter.aggregate(expression)
      end

      def self.deserialize(column, type)
        adapter.deserialize(column, type)
      end

      def self.adapter
        case ActiveRecord::Base.connection.adapter_name
        when 'SQLite', 'Mysql2'
          MysqlColumnAggregator
        when 'PostgreSQL'
          PostgresColumnAggregator
        end
      end
    end
  end
end
