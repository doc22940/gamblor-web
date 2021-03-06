class Game < ApplicationRecord
  FIRST_MARKETS = %w(blood turret dragon baron).freeze
  FIRST_MARKETS_SHORT = %w(fb ft fd fbaron win).freeze
  enum first_turret_type: [ :top, :middle, :bottom ]

  belongs_to :league
  belongs_to :split
  has_many :bets, dependent: :destroy

  validates :game_number, presence: true, numericality: { greater_than_or_equal_to: 1 }

  scope :complete, -> { where.not(winner_id: nil, loser_id: nil) }

  def self.upcoming_game_with_teams(t1, t2)
    one = where(blue_side_team_id: t1.id, red_side_team_id: t2.id, winner_id: nil)
    another = where(blue_side_team_id: t2.id, red_side_team_id: t1.id, winner_id: nil)

    if one.count > 0
      return one.first
    elsif another.count > 0
      return another.first
    else
      throw "Did not find game for #{t1.name} vs #{t2.name}"
    end
  end

  # given a game a team, get the other (not given) team
  def opposing_team(first_team)
    if blue_side_team_id == first_team.id
      return red_side_team
    end

    blue_side_team
  end

  def date_only
    date.to_s.split(' ').first
  end

  def odds_for_team_in_market(team_id, market)
    team_side = red_side_team_id == team_id ? 'red_side' : 'blue_side'

    self["#{team_side}_team_#{market}_odds"]
  end

  def winner 
    Team.find winner_id
  end

  def teams
    Team.where(id: [red_side_team_id, blue_side_team_id])
  end

  def loser
    Team.find loser_id
  end

  def red_side_team
    Team.find red_side_team_id
  end

  def blue_side_team
    Team.find blue_side_team_id
  end

  def first_team_to_get(market)
    id = self["first_#{market}_team_id"]
    Team.find id if id
  end

  def player_to_get_first(market)
    id = self["first_#{market}_player_id"]
    Player.find id if id
  end

  def complete?
    !winner_id.nil? && !loser_id.nil?
  end
end
