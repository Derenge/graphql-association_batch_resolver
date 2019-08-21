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
    end
  end
end
