def get_success_at_given_date(team, market, date)
  games = team.games.where('date < ?', date)
  success = 0.0

  games.each do |game|
    if game[MarketBetMapper.map(market)] == team.id
      success += 1
    end
  end

  success / games.count
end

def build_recommendation(game, ev, team, opponent, odds, market)
  {
    game: game,
    date: game.date, 
    ev: ev.round(2),
    team: team, 
    market: market,
    odds: odds,
    opponent: opponent
  }
end

#
# options = { min_ev, min_success_percentage_diff }
# min_ev: the ev must be at least this much to bet
# min_success_percentage_diff: only bet if Team A's success % is at least much greater than Team B's
#
def get_reccomendations(test, train, market, options)
  min_ev = options[:min_ev]
  min_success_percentage_diff = options[:min_success_percentage_diff]
  recommendations = []

  test.each do |game|
    team_1, team_2, red = game.teams
    blue = game.blue_side_team_id == team_1.id ? team_1 : team_2
    red = blue == team_1 ? team_2 : team_1

    blue_percent = get_success_at_given_date(blue, market, game.date)
    red_percent = get_success_at_given_date(red, market, game.date)

    blue_odds = game["blue_side_team_#{market}_odds"]
    red_odds = game["red_side_team_#{market}_odds"]

    blue_ev = ((blue_percent + (1 - red_percent)) / 2) * blue_odds
    red_ev = ((red_percent + (1 - blue_percent)) / 2) * red_odds

    diff = min_success_percentage_diff

    if blue_ev > min_ev and (blue_percent - red_percent) > diff
      recommendations << build_recommendation(game, blue_ev, blue, red, blue_odds, market)
    end

    if red_ev > min_ev and (red_percent - blue_percent) > diff
      recommendations << build_recommendation(game, red_ev, red, blue, red_odds, market)
    end
  end

  recommendations
end

# returns an array of simulations based on recommendations.
#
# A recommendation has the following:
# game: game,
# date: game.date, 
# ev: ev.round(2),
# team: team, 
# market: market,
# odds: odds,
# opponent: opponent
#
# A simuation has the following:
def run_simulation(options, recommendations, weigh)
  bank = options[:bankroll]
  bank_init = bank
  wins = 0
  bet_amt = options[:bet_amt]
  outcomes = []

  recommendations.each do |r|
    modded_bet_amount = bet_amt

    if weigh
      if r[:ev] > 1 && r[:ev] < 1.1
        modded_bet_amount = bet_amt * 1
      elsif r[:ev] > 1.1 && r[:ev] < 1.2
        modded_bet_amount = 40 # bet_amt * 1.1
      elsif r[:ev] > 1.2
        modded_bet_amount = 50 #bet_amt * 1.2
      end
    end

    bank -= modded_bet_amount

    puts "#{r[:date].strftime('%F')}: Bet $#{bet_amt} on #{r[:team][:name]} to get #{r[:market]} vs #{r[:opponent][:name]} @ #{r[:odds]}. Normalized EV: #{r[:ev]}"

    result = nil

    won = r[:game][MarketBetMapper.map(r[:market])] == r[:team][:id]

    if r[:game][MarketBetMapper.map(r[:market])] == r[:team][:id]
      puts "Won $#{(bet_amt * r[:odds]).round(2)}"
      bank += (modded_bet_amount * r[:odds])
      wins += 1
      result = 1
    else
      result = 0
      puts "Lost $#{modded_bet_amount}"
    end
    puts "Balance: #{bank.round(2)}\n\n"

    outcomes << SimulationResult.new(
      r[:date],
      r[:team],
      r[:opponent],
      r[:market],
      r[:ev],
      r[:odds],
      modded_bet_amount,
      won
    )
  end

  puts "Initial bankroll: $#{bank_init}"

  percent_profit = ((bank.round(2) - bank_init) / bank_init) * 100
  puts "Closing balance after #{recommendations.count} bets: #{bank.round(2)}"
  puts "Wins: #{wins} / #{recommendations.count}"
  puts "% Profit: #{percent_profit.round(1)}%"

  return {
    :percent_profit => percent_profit,
    :bets => recommendations.count
  }
  # outcomes
end

task :random_2, [] => :environment do |t, args|
  train = Game.where('date > ? and date < ?', Date.new(2019, 1, 1), Date.new(2019, 6, 1)).where(split_id: 4)
  test = Game.where('date > ? and date < ?', Date.new(2019, 6, 1), Date.new(2020, 7, 1)).where.not(winner_id: nil)

  evs = [1.0, 1.05, 1.10, 1.15, 1.20]
  diffs = [0.0, 0.10, 0.15, 0.20]
  results = []

  evs.each do |ev|
    diffs.each do |diff|

      markets = ['fb', 'ft', 'fd', 'fbaron']
      recommendations = []

      markets.each do |market|
        recommendations += get_reccomendations(
          test, train, market, { :min_ev => ev, :min_success_percentage_diff => diff })
      end

      sim_results = run_simulation({ :bankroll => 197, :bet_amt => 30 }, recommendations, true)
      sim_results[:ev] = ev
      sim_results[:diff] = diff
      results << sim_results
    end
  end

  results.sort! { |a, b| b[:percent_profit] <=> a[:percent_profit] }
  puts "| EV \t Diff \t Bets \t Profit \t"
  puts "--------------------------------"
  results.each do |res|
    puts "| #{res[:ev]} \t #{res[:diff]} \t #{res[:bets]} #{res[:bets] < 10 ? ' ' : ''}  \t #{res[:percent_profit].round(0)}"
  end
end
