require "test_helper"
require 'cacheql/association_loader'

class GraphQL::BatchResolver::AssociationResolverTest < Minitest::Test
  class Model < ActiveRecord::Base
    belongs_to :foo
  end

  def subject

    GraphQL::BatchResolver.for(Model, :foo)
  end

  def test_instance_delegates_model_to_class
    GraphQL::Batch.batch do
      instance = subject.new(object: nil, context: nil)
      assert instance.model == Model
      assert instance.association == :foo
    end
  end
end
