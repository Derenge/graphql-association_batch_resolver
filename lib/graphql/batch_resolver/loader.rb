module GraphQL
  module BatchResolver
    class Loader < GraphQL::Batch::Loader
      attr_accessor :scope
      attr_reader :association, :model

      def cache_key(record)
        record.object_id
      end

      def initialize(model, association)
        @association = association
        @model = model
      end

      def load(record)
        unless record.is_a?(model)
          raise TypeError, "Loader for #{model} can't load associations for #{record.class} objects"
        end

        return Promise.resolve(record) if association_loaded?(record)
        super
      end

      def perform(records)
        preload_association(records)
        records.each { |record| fulfill(record, record) }
      end

      private

      def association_loaded?(record)
        record.association(association).loaded?
      end

      def preload_association(records)
        ActiveRecord::Associations::Preloader.new.preload(records, association, preload_scope)
      end
    end
  end
end
