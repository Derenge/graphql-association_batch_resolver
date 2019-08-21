# frozen_string_literal: true

require 'graphql/association_batch_resolver/version'
require 'graphql'
require 'graphql/batch'
require 'graphql/association_batch_resolver/resolver_builder'

module GraphQL
  module AssociationBatchResolver
    class Error < StandardError; end
    class InvalidModel < Error; end
    class InvalidAssociation < Error; end

    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= Configuration.new
      end
    end

    def self.for(model, association)
      ResolverBuilder.new(model, association).resolver
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      attr_accessor :loader

      def initialize
        @loader = GraphQL::AssociationBatchResolver::AssociationLoader
      end
    end
  end
end
