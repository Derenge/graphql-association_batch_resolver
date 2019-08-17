require "test_helper"

class GraphQL::BatchResolverTest < Minitest::Test
  class NotModel; end

  class Model < ActiveRecord::Base
    belongs_to :foo
  end


  def test_that_it_has_a_version_number
    refute_nil ::GraphQL::BatchResolver::VERSION
  end

  def test_for_validates_model_is_active_record_descendant
    assert_raises(GraphQL::BatchResolver::InvalidModel) do
      GraphQL::BatchResolver.for(NotModel, :foo)
    end
  end

  def test_for_validates_association_is_symbol
    error = assert_raises(GraphQL::BatchResolver::InvalidAssociation) do
      GraphQL::BatchResolver.for(Model, 'string')
    end

    assert_match /Symbol/, error.message
  end

  def test_for_validates_association_exists_on_model
    error = assert_raises(GraphQL::BatchResolver::InvalidAssociation) do
      GraphQL::BatchResolver.for(Model, :not_an_association)
    end

    assert_match /does not exist/, error.message
  end

  def test_returns_named_resolver
    resolver = GraphQL::BatchResolver.for(Model, :foo)

    assert_equal "#{Model.name}::FooResolver", resolver.name
  end
end
