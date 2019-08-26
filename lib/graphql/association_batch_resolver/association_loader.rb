# frozen_string_literal: true

require_relative 'column_aggregator'

module GraphQL
  module AssociationBatchResolver
    class AssociationLoader < GraphQL::Batch::Loader
      attr_reader :model, :model_primary_key, :association_name, :is_collection, :association_model,
                  :association_primary_key, :options
      attr_accessor :scope, :context, :args

      def self.validate(model, association_name, options = {})
        new(model, association_name, options)
        nil
      end

      def initialize(model, association_name, options = {})
        @model = model
        @association_name = association_name
        @options = options
        validate
        @model_primary_key = model.primary_key
        association = @model.reflect_on_association(association_name)
        @is_collection = association.collection?
        @association_model = association.klass
        @association_primary_key = @association_model.primary_key
      end

      def load(record)
        raise TypeError, "#{model} loader can't load association for #{record.class}" unless record.is_a?(model)

        super
      end

      # We want to load the associations on all records, even if they have the same id
      def cache_key(record)
        record.object_id
      end

      def perform(records)
        preload_association(records)
        records.each { |record| fulfill(record, read_association(record)) }
      end

      private

      def validate
        association_exists = !model.reflect_on_association(association_name).nil?
        raise ArgumentError, "No association #{association_name} on #{model}" unless association_exists
      end

      def preload_association(records)
        association_records = associations_for(records)
        association_records = options[:scope].call(association_records, context, *args) if options[:scope].respond_to?(:call)
        find_by_sql = association_records.to_sql

        self.scope = if find_by_sql.present?
                       association_model.find_by_sql(find_by_sql).to_a
                     else
                       []
                     end
      end

      # rubocop:disable Metrics/AbcSize
      def associations_for(records)
        select_model_primary_keys = ColumnAggregator.aggregate([model.arel_table[model_primary_key]])
        self.scope = model.where(model_primary_key => records)
                          .joins(association_name)
                          .select(association_model.arel_table[Arel.star])
                          .select(select_model_primary_keys.as('model_primary_keys'))
                          .group(association_model.arel_table[association_primary_key])
      end
      # rubocop:enable Metrics/AbcSize

      def read_association(model_record)
        key = model_record.send(model_primary_key)

        type = model.type_for_attribute(model_primary_key)
        association_scope = scope.select do |association_record|
          ColumnAggregator.deserialize(association_record.model_primary_keys, type).include?(key)
        end

        is_collection ? association_scope : association_scope.first
      end
    end
  end
end
