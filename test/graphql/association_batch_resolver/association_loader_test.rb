# frozen_string_literal: true

require 'test_helper'

module GraphQL
  module AssociationBatchResolver
    class AssociationLoaderTest < Minitest::Test
      def subject
        GraphQL::AssociationBatchResolver::AssociationLoader
      end

      def query_count_and_batch_result(expected_query_count: 1)
        result = nil
        query_count = QueryCounterHelper.count do
          result = GraphQL::Batch.batch do
            yield
          end
        end

        assert_equal expected_query_count, query_count
        result
      end

      def setup_belongs_to
        players = [Player.create, Player.create, Player.create]
        teams = players.map { |p| Team.create(players: [p]) }

        _missing_team = Team.create

        [players, teams]
      end

      def test_batches_belongs_to_associations
        players, teams = setup_belongs_to
        loaded = query_count_and_batch_result do
          loader = subject.for(Player, :team)

          Promise.all(players.map { |player| loader.load(player) }).sync
        end

        assert_equal teams, loaded
      end

      def setup_has_one
        players = [Player.create, Player.create, Player.create]
        ranks = players.map { |p| Rank.create(player: p) }

        _missing_player = Player.create

        [players, ranks]
      end

      def test_batches_has_one_associations
        players, ranks = setup_has_one
        loaded = query_count_and_batch_result do
          loader = subject.for(Player, :rank)

          Promise.all(players.map { |player| loader.load(player) }).sync
        end

        assert_equal ranks, loaded
      end

      def setup_has_many
        team1_players = [Player.create, Player.create, Player.create]
        team2_players = [Player.create, Player.create, Player.create]
        players = [team1_players, team2_players, []]

        team1 = Team.create(players: team1_players)
        team2 = Team.create(players: team2_players)
        teams = [team1, team2, Team.create]

        _missing_player = Player.create

        [players, teams]
      end

      def test_batches_has_many_associations
        players, teams = setup_has_many
        loaded = query_count_and_batch_result do
          loader = subject.for(Team, :players)

          Promise.all(teams.map { |team| loader.load(team) }).sync
        end

        assert_equal players, loaded
      end

      def setup_has_many_through
        team1_players = [Player.create, Player.create, Player.create]
        team2_players = [Player.create, Player.create]

        team1_ranks = team1_players.map { |player| Rank.create(player: player) }
        team2_ranks = team2_players.map { |player| Rank.create(player: player) }

        team1 = Team.create(players: team1_players)
        team2 = Team.create(players: team2_players)

        teams = [team1, team2]
        ranks = [team1_ranks, team2_ranks]

        [teams, ranks]
      end

      def test_batches_has_many_through_associations
        teams, ranks = setup_has_many_through
        loaded = query_count_and_batch_result do
          loader = subject.for(Team, :ranks)

          Promise.all(teams.map { |team| loader.load(team) }).sync
        end

        assert_equal ranks, loaded
      end

      def setup_habtm
        player1 = Player.create(games: [Game.create, Game.create])
        player2 = Player.create(games: [Game.create, Game.create, Game.create])

        players = [player1, player2]
        games = players.map(&:games)

        [players, games]
      end

      def test_batches_habtm_associations
        players, games = setup_habtm
        loaded = query_count_and_batch_result do
          loader = subject.for(Player, :games)

          Promise.all(players.map { |player| loader.load(player) }).sync
        end

        assert_equal games, loaded
      end

      def mod_ids
        proc { |scope, _context, remainder: 0| scope.where('teams.id % 2 = ?', remainder) }
      end

      def test_it_supports_scope_option
        players, teams = setup_belongs_to
        expected_teams = teams.map { |t| t.id.even? ? t : nil }
        loaded = query_count_and_batch_result do
          loader = subject.for(Player, :team, scope: mod_ids)

          Promise.all(players.map { |player| loader.load(player) }).sync
        end

        assert_equal expected_teams, loaded
      end

      def test_it_passes_arguments_to_scope
        players, teams = setup_belongs_to
        expected_teams = teams.map { |t| t.id.odd? ? t : nil }
        loaded = query_count_and_batch_result do
          loader = subject.for(Player, :team, scope: mod_ids)
          loader.args = [remainder: 1]

          Promise.all(players.map { |player| loader.load(player) }).sync
        end

        assert_equal expected_teams, loaded
      end

      def test_it_handles_empty_sql
        players, = setup_belongs_to
        expected_teams = [nil, nil, nil]
        loaded = query_count_and_batch_result(expected_query_count: 0) do
          loader = subject.for(Player, :team, scope: proc {|scope, _context| scope.none})

          Promise.all(players.map { |player| loader.load(player) }).sync
        end

        assert_equal expected_teams, loaded
      end
    end
  end
end
