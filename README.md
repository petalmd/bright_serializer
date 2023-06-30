[![Actions Status](https://github.com/petalmd/bright_serializer/workflows/Build/badge.svg)](https://github.com/petalmd/bright_serializer/actions?query=workflow%3ABuild)
[![Gem Version](https://badge.fury.io/rb/bright_serializer.svg)](https://badge.fury.io/rb/bright_serializer)
[![Coverage Status](https://coveralls.io/repos/github/petalmd/bright_serializer/badge.svg?branch=master)](https://coveralls.io/github/petalmd/bright_serializer?branch=master)

# BrightSerializer

This is a very light and fast gem to serialize object in a Ruby project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bright_serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bright_serializer

## Usage and features

### Basic

Create a class and include `BrightSerializer::Serializer`

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name

  # With a block
  attribute :name do |object|
    "#{object.first_name} #{object.last_name}"
  end

  # With a block shorter
  attribute :created_at, &:to_s
end

AccountSerializer.new(Account.first).to_h
AccountSerializer.new(Account.first).to_json
```

### Params

You can pass params to your serializer. For example to have more context with the authenticated user.

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name

  attribute :friend do |object, params|
    object.is_friend_with? params[:current_user]
  end
end

current_user = Account.find(authenticated_account_id)
AccountSerializer.new(Account.first, params: { current_user: current_user }).to_json
```

### Conditional Attributes

Attribute can be remove from serialization by passing a `proc` to the option `if`. If the proc return `true` the attibute
 will be serialize. `object` and `params` or accessible.

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name

  attribute :email, if: proc { |object, params| params[:current_user].is_admin? }
end
```

### Transform keys

By default, keys or not transformed.

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  set_key_transform :underscore
end

set_key_transform :underscore # "first_name" => "first_name"
set_key_transform :camel # "first_name" => "FirstName"
set_key_transform :camel_lower # "first_name" => "firstName"
set_key_transform :dash # "first_name" => "first-name"
```

### Instance serializer fieldsets

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
end

# Only serialize first_name and last_name
AccountSerializer.new(Account.first, fields: [:first_name, :last_name]).to_json
```

### Relations

`has_one`, `has_many` and `belongs_to` helper methods can be use to use an other
serializer for nested attributes and relations.

* The `serializer` option must be provided.

When using theses methods you can pass options that will be apply like any other attributes.

* The option `if` can be pass to show or hide the relation.
* The option `entity` to generate API documentation.
* The option `fields` to only serializer some attributes of the nested object.
* The option `params` can be passed, it will be merged with the parent params.
* A block can be passed and the return value will be serialized with the `serializer` passed.

```ruby
class FriendSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name
end

class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :first_name, :last_name

  has_many :friends, serializer: 'FriendSerializer'
end
```

```ruby
# Block
has_one :best_friend, serializer: 'FriendSerializer' do |object, params|
 # ...
end

# If
belongs_to :best_friend_of, serializer: 'FriendSerializer', if: proc { |object, params| '...' }

# Fields
has_one :best_friend, serializer: 'FriendSerializer', fields: [:first_name, :last_name]

# Params
has_one :best_friend, serializer: 'FriendSerializer', params: { static_param: true }

# Entity
has_one :best_friend, serializer: 'FriendSerializer', entity: { description: '...' }
```

### Entity

You can define the entity of your serializer to generate documentation with the option `entity`.
The feature was build to work with [grape-swagger](https://github.com/ruby-grape/grape-swagger).
For more information about defining a model entity see the [Swagger documentation](https://swagger.io/specification/v2/?sbsearch=array%20response#schema-object).

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attribute :id, entity: { type: :string, description: 'The id of the account' }
  attribute :name

  has_many :friends, serializer: 'FriendSerializer',
    entity: {
      type: :array, description: 'The list the account friends.'
     }
end
```

Callable values are supported.

```ruby
{ entity: { type: :string, enum: -> { SomeModel::ENUMVALUES } } }
```

For relations only `type` need to be defined, `ref` will use the same class has `serializer`.

```ruby
has_many :friends, serializer: 'FriendSerializer', entity: { type: :array }
has_one :best_friend, serializer: 'FriendSerializer', entity: { type: :object }
```

### Instance

If you have defined instance methods inside your serializer you can access them inside block attribute.

```ruby
class AccountSerializer
  include BrightSerializer::Serializer
  attributes :id, :name

  attribute :print do |object|
    print_account(object)
  end

  def print_account(object)
    "Account: #{object.name}"
  end
end
```

### Deprecations

#### Serializing nil ([#103](https://github.com/petalmd/bright_serializer/issues/103))

In version `v0.6.X` passing `nil` will raise a warning and still continue to return all attributes with nil. 

```ruby
MySerializer.new(nil).to_hash # => { id: nil, name: nil }
```

To use the future default behavior (`v0.7.X`), you can use the class option `serialize_nil_if_nil`.

```ruby
class MySerializer
  include BrightSerializer::Serializer
  serialize_nil_if_nil
  # ...
end

MySerializer.new(nil).to_hash # => nil
```

## Benchmark

Event if the main goal is not performance, it has very good result.

```sh
ruby benchmarks/collection.rb
```

<img src="benchmarks/ips.png" width="400px">

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## New release

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/petalmd/bright_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
