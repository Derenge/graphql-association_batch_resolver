# frozen_string_literal: true

class QueryCounterHelper
  def self.count
    queries = Set.new
    callback = lambda do |_name, _start, _finish, _id, payload|
      queries.add(payload) unless payload[:name] == 'SCHEMA'
    end
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      yield
    end
    queries.size
  end
end
