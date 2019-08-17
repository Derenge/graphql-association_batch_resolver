require 'graphql/batch_resolver/association_resolver'

module GraphQL
  module BatchResolver
    class ResolverBuilder
      attr_accessor :model, :association

      def initialize(model, association)
        @model = model
        @association = association
      end

      def resolver_class_name
        @resolver_class_name ||= "#{association_class_name}Resolver"
      end

      def association_class_name
        association.to_s.classify
      end

      def resolver
        define_resolver unless model.const_defined?(resolver_class_name)

        model.const_get(resolver_class_name)
      end

      def define_resolver
        resolver = Class.new(AssociationResolver)
        resolver.model = model
        resolver.association = association

        model.const_set(resolver_class_name, resolver)

        resolver.validate!
      end
    end
  end
end
