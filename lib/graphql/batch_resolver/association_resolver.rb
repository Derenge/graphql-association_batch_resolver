require 'forwardable'
require 'cacheql'

module GraphQL
  module BatchResolver
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
          is_symbol = association.is_a?(Symbol)

          raise InvalidAssociation, 'Association must be a Symbol object' unless is_symbol

          is_association = !model.reflect_on_association(association).nil?

          raise InvalidAssociation, "Association :#{association} does not exist on #{model}" unless is_association
        end
      end

      extend Forwardable

      def_delegators :'self.class', :model, :association, :loader
      attr_accessor :loader

      def initialize(*)
        super
        @loader = CacheQL::AssociationLoader.for(model, association)
      end

      def resolve(*)
        loader.load(object)
      end
    end
  end
end
