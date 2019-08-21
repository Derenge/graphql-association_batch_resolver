# frozen_string_literal: true

require 'forwardable'

module GraphQL
  module AssociationBatchResolver
    class AssociationResolver < GraphQL::Schema::Resolver
      class << self
        attr_accessor :model, :association

        def validate!
          validate_model!
          validate_association!
        end

        def validate_model!
          is_active_record_model = model < ActiveRecord::Base

          raise InvalidModel, "Model (#{model}) must be an ActiveRecord::Base descendant" unless is_active_record_model
        end

        def validate_association!
          is_association = !model.reflect_on_association(association).nil?

          raise InvalidAssociation, "Association :#{association} does not exist on #{model}" unless is_association
        end
      end

      extend Forwardable

      def_delegators :'self.class', :model, :association
      attr_accessor :loader

      def initialize(*args, loader_class: GraphQL::AssociationBatchResolver.configuration.loader, **keywargs, &block)
        super(*args, **keywargs, &block)
        @loader = loader_class.for(model, association)
      end

      def resolve(*)
        loader.load(object)
      end
    end
  end
end
