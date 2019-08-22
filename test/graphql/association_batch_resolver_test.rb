# frozen_string_literal: true

require 'test_helper'

module GraphQL
  class AssociationBatchResolverTest < Minitest::Test
    class NotModel
    end

    def test_that_it_has_a_version_number
      refute_nil ::GraphQL::AssociationBatchResolver::VERSION
    end

    def test_for_validates_model_is_active_record_descendant
      assert_raises(AssociationBatchResolver::InvalidModel) do
        AssociationBatchResolver.for(NotModel, :foo)
      end
    end

    def test_for_validates_association_exists_on_model
      error = assert_raises(AssociationBatchResolver::InvalidAssociation) do
        AssociationBatchResolver.for(Player, :not_an_association)
      end

      assert_match(/does not exist/, error.message)
    end

    def test_returns_named_resolver
      resolver = AssociationBatchResolver.for(Player, :team)

      assert_equal 'Player::TeamResolver', resolver.name
    end

    def test_it_passes_options_to_loader
      options = {}
      GraphQL::Batch.batch do
        resolver = AssociationBatchResolver.for(Player, :team, options)
        instance = resolver.new(object: nil, context: nil)
        assert_equal options, instance.options
      end
    end
  end
end
