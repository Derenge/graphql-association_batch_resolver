require "graphql/batch_resolver/version"
require 'graphql'
require 'graphql/batch_resolver/resolver_builder'

module GraphQL
  module BatchResolver
    class Error < StandardError; end
    class InvalidModel < Error; end
    class InvalidAssociation < Error; end

    def self.for(model, association)
      ResolverBuilder.new(model, association).resolver
    end
  end
end
