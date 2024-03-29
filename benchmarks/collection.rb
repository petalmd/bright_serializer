# frozen_string_literal: true

# Source: https://github.com/okuramasafumi/alba/blob/main/benchmark/collection.rb

# Benchmark script to run varieties of JSON serializers
# Fetch Alba from local, otherwise fetch latest from RubyGems

# --- Bundle dependencies ---

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'
  gem 'active_model_serializers'
  gem 'activerecord', '6.1.3'
  gem 'alba'
  gem 'benchmark-ips'
  gem 'benchmark-memory'
  gem 'blueprinter'
  gem 'fast_serializer_ruby'
  gem 'jbuilder'
  gem 'turbostreamer'
  gem 'jserializer'
  gem 'multi_json'
  gem 'panko_serializer'
  gem 'primalize'
  gem 'oj'
  gem 'representable'
  gem 'simple_ams'
  gem 'sqlite3'
  gem 'bright_serializer', path: './'

  gem 'gruff'
end

# --- Test data model setup ---

require 'active_record'
require 'logger'
require 'oj'
require 'sqlite3'
Oj.optimize_rails

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :body
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :body
    t.integer :commenter_id
  end

  create_table :users, force: true do |t|
    t.string :name
  end
end

class Post < ActiveRecord::Base
  has_many :comments
  has_many :commenters, through: :comments, class_name: 'User', source: :commenter

  def attributes
    { id: nil, body: nil, commenter_names: commenter_names }
  end

  def commenter_names
    commenters.map(&:name)
  end
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :commenter, class_name: 'User'

  def attributes
    { id: nil, body: nil }
  end
end

class User < ActiveRecord::Base
  has_many :comments
end

# --- Alba serializers ---

require 'alba'

class AlbaCommentResource
  include ::Alba::Resource
  attributes :id, :body
end

class AlbaPostResource
  include ::Alba::Resource
  attributes :id, :body
  attribute :commenter_names do |post|
    post.commenters.map(&:name)
  end
  many :comments, resource: AlbaCommentResource
end

# --- ActiveModelSerializer serializers ---

require 'active_model_serializers'

ActiveModelSerializers.logger = Logger.new(nil)

class AMSCommentSerializer < ActiveModel::Serializer
  attributes :id, :body
end

class AMSPostSerializer < ActiveModel::Serializer
  attributes :id, :body
  attribute :commenter_names
  has_many :comments, serializer: AMSCommentSerializer

  def commenter_names
    object.commenters.map(&:name)
  end
end

# --- Blueprint serializers ---

require 'blueprinter'

class CommentBlueprint < Blueprinter::Base
  fields :id, :body
end

class PostBlueprint < Blueprinter::Base
  fields :id, :body, :commenter_names
  association :comments, blueprint: CommentBlueprint

  def commenter_names
    commenters.map(&:name)
  end
end

# --- Fast Serializer Ruby

require 'fast_serializer'

class FastSerializerCommentResource
  include ::FastSerializer::Schema::Mixin
  attributes :id, :body
end

class FastSerializerPostResource
  include ::FastSerializer::Schema::Mixin

  attributes :id, :body

  attribute :commenter_names do
    object.commenters.map(&:name)
  end

  has_many :comments, serializer: FastSerializerCommentResource
end

# --- JBuilder serializers ---

require 'jbuilder'

class Post
  def to_builder
    Jbuilder.new do |post|
      post.call(self, :id, :body, :commenter_names, :comments)
    end
  end

  def commenter_names
    commenters.map(&:name)
  end
end

class Comment
  def to_builder
    Jbuilder.new do |comment|
      comment.call(self, :id, :body)
    end
  end
end

# --- Jserializer serializers ---

require 'jserializer'

class JserializerCommentSerializer < Jserializer::Base
  attributes :id, :body
end

class JserializerPostSerializer < Jserializer::Base
  attributes :id, :body, :commenter_names
  has_many :comments, serializer: JserializerCommentSerializer
  def commenter_names
    object.commenters.map(&:name)
  end
end

# --- Panko serializers ---
#

require 'panko_serializer'

class PankoCommentSerializer < Panko::Serializer
  attributes :id, :body
end

class PankoPostSerializer < Panko::Serializer
  attributes :id, :body, :commenter_names

  has_many :comments, serializer: PankoCommentSerializer

  def commenter_names
    object.commenters.map(&:name)
  end
end

# --- Primalize serializers ---
#
class PrimalizeCommentResource < Primalize::Single
  attributes id: integer, body: string
end

class PrimalizePostResource < Primalize::Single
  alias post object

  attributes(
    id: integer,
    body: string,
    comments: array(primalize(PrimalizeCommentResource)),
    commenter_names: array(string)
  )

  def commenter_names
    post.commenters.map(&:name)
  end
end

class PrimalizePostsResource < Primalize::Many
  attributes posts: enumerable(PrimalizePostResource)
end

# --- Representable serializers ---

require 'representable'

class CommentRepresenter < Representable::Decorator
  include Representable::JSON

  property :id
  property :body
end

class PostsRepresenter < Representable::Decorator
  include Representable::JSON::Collection

  items class: Post do
    property :id
    property :body
    property :commenter_names
    collection :comments
  end

  def commenter_names
    commenters.map(&:name)
  end
end

# --- SimpleAMS serializers ---

require 'simple_ams'

class SimpleAMSCommentSerializer
  include SimpleAMS::DSL

  attributes :id, :body
end

class SimpleAMSPostSerializer
  include SimpleAMS::DSL

  attributes :id, :body
  attribute :commenter_names
  has_many :comments, serializer: SimpleAMSCommentSerializer

  def commenter_names
    object.commenters.map(&:name)
  end
end

require 'turbostreamer'
TurboStreamer.set_default_encoder(:json, :oj)

class TurbostreamerSerializer
  def initialize(posts)
    @posts = posts
  end

  def to_json(*_args)
    TurboStreamer.encode do |json|
      json.array! @posts do |post|
        json.object! do
          json.extract! post, :id, :body, :commenter_names

          json.comments post.comments do |comment|
            json.object! do
              json.extract! comment, :id, :body
            end
          end
        end
      end
    end
  end
end

require 'bright_serializer'

class BrightCommentSerializer
  include BrightSerializer::Serializer

  attributes :id, :body
end

class BrightPostSerializer
  include BrightSerializer::Serializer

  attributes :id, :body
  attribute :commenter_names
  has_many :comments, serializer: 'BrightCommentSerializer'

  attribute :commenter_names do |object|
    object.commenters.map(&:name)
  end
end

# --- Test data creation ---

1000.times do |i|
  post = Post.create!(body: "post#{i}")
  user1 = User.create!(name: "John#{i}")
  user2 = User.create!(name: "Jane#{i}")
  10.times do |n|
    post.comments.create!(commenter: user1, body: "Comment1_#{i}_#{n}")
    post.comments.create!(commenter: user2, body: "Comment2_#{i}_#{n}")
  end
end

graph_data = {}

require 'benchmark/ips'

iterations = [50, 100, 500, 1000]
iterations.each do |n|
  posts = Post.limit(n).includes(:comments, :commenters)

  # --- Store the serializers in procs ---

  alba = proc { AlbaPostResource.new(posts).serialize }
  alba_inline = proc do
    Alba.serialize(posts) do
      attributes :id, :body
      attribute :commenter_names do |post|
        post.commenters.map(&:name)
      end
      many :comments do
        attributes :id, :body
      end
    end
  end
  ams = proc { ActiveModelSerializers::SerializableResource.new(posts, { each_serializer: AMSPostSerializer }).to_json }
  blueprinter = proc { PostBlueprint.render(posts) }
  fast_serializer = proc { FastSerializerPostResource.new(posts).to_json }
  jbuilder = proc do
    Jbuilder.new do |json|
      json.array!(posts) do |post|
        json.post post.to_builder
      end
    end.target!
  end
  jserializer = proc { JserializerPostSerializer.new(posts, is_collection: true).to_json }
  panko = proc { Panko::ArraySerializer.new(posts, each_serializer: PankoPostSerializer).to_json }
  primalize = proc { PrimalizePostsResource.new(posts: posts).to_json }
  rails = proc do
    ActiveSupport::JSON.encode(posts.map { |post| post.serializable_hash(include: :comments) })
  end
  representable = proc { PostsRepresenter.new(posts).to_json }
  simple_ams = proc { SimpleAMS::Renderer::Collection.new(posts, serializer: SimpleAMSPostSerializer).to_json }
  turbostreamer = proc { TurbostreamerSerializer.new(posts).to_json }
  bright_serializer = proc { BrightPostSerializer.new(posts).to_json }

  # --- Execute the serializers to check their output ---
  GC.disable
  # puts "Serializer outputs ----------------------------------"
  # outputs = {
  #   alba: alba,
  #   alba_inline: alba_inline,
  #   ams: ams,
  #   blueprinter: blueprinter,
  #   fast_serializer: fast_serializer,
  #   jbuilder: jbuilder, # different order
  #   jserializer: jserializer,
  #   panko: panko,
  #   primalize: primalize,
  #   rails: rails,
  #   representable: representable,
  #   simple_ams: simple_ams,
  #   turbostreamer: turbostreamer,
  #   bright_serializer: bright_serializer
  # }
  # outputs.each do |name, serializer|
  #   outputs.each do |name2, serializer2|
  #     next if name == name2
  #
  #     checksum1 = serializer.call.size
  #     checksum2 = serializer2.call.size
  #     if checksum1 != checksum2
  #       p name
  #       pp serializer.call
  #       p name2
  #       pp serializer2.call
  #       raise "Output differs for #{name} and #{name2}"
  #     end
  #   end
  # end

  # --- Run the benchmarks ---

  ips_result = Benchmark.ips do |x|
    x.report(:alba, &alba)
    # x.report(:alba_inline, &alba_inline)
    x.report(:ams, &ams)
    # x.report(:blueprinter, &blueprinter)
    x.report(:fast_serializer, &fast_serializer)
    x.report(:jbuilder, &jbuilder)
    # x.report(:jserializer, &jserializer)
    # x.report(:panko, &panko)
    # x.report(:primalize, &primalize)
    # x.report(:rails, &rails)
    # x.report(:representable, &representable)
    # x.report(:simple_ams, &simple_ams)
    # x.report(:turbostreamer, &turbostreamer)
    x.report(:bright_serializer, &bright_serializer)

    x.compare!
  end
  ips_result.entries.each do |result|
    graph_data[result.label] ||= []
    graph_data[result.label] << result.ips
  end
end

require_relative 'graph'

GraphGenerator.new(iterations, graph_data).generate_ips


# require 'benchmark/memory'
# Benchmark.memory do |x|
#   x.report(:alba, &alba)
#   x.report(:alba_inline, &alba_inline)
#   x.report(:ams, &ams)
#   x.report(:blueprinter, &blueprinter)
#   x.report(:fast_serializer, &fast_serializer)
#   x.report(:jbuilder, &jbuilder)
#   x.report(:jserializer, &jserializer)
#   x.report(:panko, &panko)
#   x.report(:primalize, &primalize)
#   x.report(:rails, &rails)
#   x.report(:representable, &representable)
#   x.report(:simple_ams, &simple_ams)
#   x.report(:turbostreamer, &turbostreamer)
#   x.report(:bright_serializer, &bright_serializer)
#
#   x.compare!
# end
