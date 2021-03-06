module Api
  module V1
    class TeamsController < ::ActionController::API
      def index
        render json: Team.all
      end

      def show
        team = Team.find(params[:id])

        render json: { 
          team: team, 
          games: team.games,
          players: team.players
        }
      end
    end
  end
end

