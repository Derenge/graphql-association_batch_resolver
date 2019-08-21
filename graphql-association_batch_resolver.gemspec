# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graphql/association_batch_resolver/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql-association_batch_resolver'
  spec.version       = GraphQL::AssociationBatchResolver::VERSION
  spec.authors       = ['Andrew Derenge']
  spec.email         = ['andrew@rigup.com']

  spec.summary       = 'GraphQL Resolver for ActiveRecord Associations'


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 5.2.0'
  spec.add_dependency 'graphql', '~> 1.9.0'
  spec.add_dependency 'graphql-batch', '~> 0.4.0'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.7.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.74.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4.1'
end
