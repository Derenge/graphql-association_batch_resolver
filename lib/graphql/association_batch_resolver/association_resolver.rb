# frozen_string_literal: true

require 'forwardable'

module GraphQL
  module AssociationBatchResolver
    class AssociationResolver < GraphQL::Schema::Resolver
      class << self
        attr_accessor :model, :association, :options

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

      def_delegators :'self.class', :model, :association, :options
      attr_accessor :loader

      def initialize(*args, loader_class: GraphQL::AssociationBatchResolver.configuration.loader, **keywargs, &block)
        super(*args, **keywargs, &block)
        initialization_arguments = [model, association]
        initialization_arguments << options if options

        @loader = loader_class.for(*initialization_arguments)
        @loader.context = context if @loader.respond_to?(:context=)
      end

      def resolve(*args)
        loader.args = *args
        loader.load(object)
      end
    end
  end
end
