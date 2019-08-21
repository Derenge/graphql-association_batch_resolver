# frozen_string_literal: true

require 'test_helper'

module GraphQL
  module AssociationBatchResolver
    class AssociationLoaderTest < Minitest::Test
      def subject
        GraphQL::AssociationBatchResolver::AssociationLoader
      end

      def setup_belongs_to
        players = [Player.create, Player.create, Player.create]
        teams = players.map { |p| Team.create(players: [p]) }

        _missing_team = Team.create

        [players, teams]
      end

      def test_batches_belongs_to_associations
        players, teams = setup_belongs_to
        query_count = QueryCounterHelper.count do
          loaded_teams = GraphQL::Batch.batch do
            loader = subject.for(Player, :team)

            Promise.all(players.map { |player| loader.load(player) }).sync
          end
          assert_equal teams, loaded_teams
        end

        assert_equal 1, query_count
      end

      def setup_has_one
        players = [Player.create, Player.create, Player.create]
        ranks = players.map { |p| Rank.create(player: p) }

        _missing_player = Player.create

        [players, ranks]
      end

      def test_batches_has_one_associations
        players, ranks = setup_has_one
        query_count = QueryCounterHelper.count do
          loaded_ranks = GraphQL::Batch.batch do
            loader = subject.for(Player, :rank)

            Promise.all(players.map { |player| loader.load(player) }).sync
          end
          assert_equal ranks, loaded_ranks
        end

        assert_equal 1, query_count
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
        query_count = QueryCounterHelper.count do
          loaded_players = GraphQL::Batch.batch do
            loader = subject.for(Team, :players)

            Promise.all(teams.map { |team| loader.load(team) }).sync
          end
          assert_equal players, loaded_players
        end

        assert_equal 1, query_count
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
        query_count = QueryCounterHelper.count do
          loaded_ranks = GraphQL::Batch.batch do
            loader = subject.for(Team, :ranks)

            Promise.all(teams.map { |team| loader.load(team) }).sync
          end
          assert_equal ranks, loaded_ranks
        end

        assert_equal 1, query_count
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
        query_count = QueryCounterHelper.count do
          loaded_games = GraphQL::Batch.batch do
            loader = subject.for(Player, :games)

            Promise.all(players.map { |player| loader.load(player) }).sync
          end
          assert_equal games, loaded_games
        end

        assert_equal 1, query_count
      end
    end
  end
end
