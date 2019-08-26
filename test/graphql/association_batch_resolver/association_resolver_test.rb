# frozen_string_literal: true

require 'test_helper'
module GraphQL
  module AssociationBatchResolver
    class AssociationResolverTest < Minitest::Test
      def subject
        GraphQL::AssociationBatchResolver.for(Player, :team)
      end

      def test_instance_delegates_model_to_class
        GraphQL::Batch.batch do
          instance = subject.new(object: nil, context: nil)
          assert instance.model == Player
          assert instance.association == :team
        end
      end

      def test_it_passes_on_options
        GraphQL::Batch.batch do
          opts = {foo: :bar}
          AssociationResolver.model = Player
          AssociationResolver.association = :team
          AssociationResolver.options = opts
          resolver = AssociationResolver.new(object: nil, context: nil)
          assert_equal opts, resolver.loader.options
        end
      end

      def test_it_passes_on_context
        GraphQL::Batch.batch do
          context = {foo: :bar}
          AssociationResolver.model = Player
          AssociationResolver.association = :team
          resolver = AssociationResolver.new(object: nil, context: context)
          assert_equal context, resolver.loader.context
        end
      end

      def test_it_passes_on_arguments
        GraphQL::Batch.batch do
          context = {foo: :bar}
          AssociationResolver.model = Player
          player = Player.new
          AssociationResolver.association = :team
          resolver = AssociationResolver.new(object: player, context: context)
          resolver.resolve(where: :foo)
          assert resolver.loader.args = {where: :foo}
        end
      end
    end
  end
end
