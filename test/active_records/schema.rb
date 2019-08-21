# frozen_string_literal: true

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  original_stdout = $stdout
  $stdout = StringIO.new
  begin
    create_table :players do |t|
      t.belongs_to :team
    end

    create_table :games do |t|
    end

    create_join_table :games, :players

    create_table :teams do |t|
    end

    create_table :ranks do |t|
      t.belongs_to :player
    end
  ensure
    $stdout = original_stdout
  end
end
