# GraphQL::AssociationBatchResolver

A resolver for [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) that batch loads active record associations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'association_batch_resolver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-association_batch_resolver

## Usage

```ruby
# Model definition
class Player < ActiveRecord::Base
  belongs_to :team
  
end

# Type definition
class PlayerType < GraphQL::Schema::Object
  field :team, resolver: GraphQL::AssociationBatchResolver.for(Player, :team) 
end

```

**GraphQL::AssociationBatchResolver#for**
 * Arguments
   * model - ActiveRecord::Base descendant
   * association - Any ActiveRecord association name on `model`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/derenge/graphql-association_batch_resolver.
