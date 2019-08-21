# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'pry-byebug'
require 'graphql/association_batch_resolver'
require_relative 'active_record_helper'
require_relative 'query_counter_helper'
