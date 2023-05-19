class LeagueStanding
  POINTS = {
    win: 3,
    draw: 1,
    loss: 0
  }.freeze

  MATCH_TEXT_REGEX = Regexp.new('.+ \d+, .+ \d+').freeze
  RESULT_REGEX = Regexp.new('(?<team>.+) (?<score>\d+)').freeze

  def initialize
    @games_played = Hash.new(0)
    @processed_standings = Hash.new(0)
    @match_day_is_complete = false
    @completed_match_day_number = 0
  end

  attr_reader :games_played, :completed_match_day_number, :end_of_match_day_standings,
              :processed_standings

  def match_day_complete?
    @match_day_is_complete
  end

  def end_of_match_day_standings(limit: nil)
    return if @end_of_match_day_standings.nil?

    limit ||= @end_of_match_day_standings.size
    @end_of_match_day_standings.take(limit).to_h
  end

  def process_match(match_text)
    unless MATCH_TEXT_REGEX.match?(match_text) || match_text == 'END'
      return :invalid_text
    end

    current_games_played = games_played.dup
    current_standings = processed_standings.dup

    if equal_played_match_count?(current_games_played) && match_text == 'END'
      set_completed_match_day(current_standings)
      return :valid_text
    elsif match_text == 'END'
      set_incomplete_match_day
      return :valid_text
    end

    team_1_result, team_2_result =
      match_text.split(', ').map { |r| extract_team_and_score(r) }

    [team_1_result, team_2_result]
      .each { |result| games_played[result['team']] += 1 }

    if team_1_result['score'] == team_2_result['score']
      update_standings(team_1_result['team'], :draw)
      update_standings(team_2_result['team'], :draw)
    elsif team_1_result['score'] > team_2_result['score']
      update_standings(team_1_result['team'], :win)
      update_standings(team_2_result['team'], :loss)
    elsif team_1_result['score'] < team_2_result['score']
      update_standings(team_1_result['team'], :loss)
      update_standings(team_2_result['team'], :win)
    end

    updated_games_played = games_played

    if equal_played_match_count?(current_games_played) &&
       unequal_played_match_count?(updated_games_played)

      set_completed_match_day(current_standings)
    else
      set_incomplete_match_day
    end

    @processed_standings = @processed_standings.sort_by { |team, points| [-points, team] }.to_h

    # There might be a Ruby bug afoot here; the hash default assigned in the
    # class constructor reverts to nil after initially assigning kv pairs.
    @processed_standings.default = 0
    @games_played.default = 0
    :valid_text
  end

  private

  def equal_played_match_count?(games_played)
    games_played.values.uniq.one?
  end

  def unequal_played_match_count?(games_played)
    games_played.values.uniq.size == 2
  end

  def set_completed_match_day(standings)
    @match_day_is_complete = true
    @end_of_match_day_standings = standings
    @completed_match_day_number += 1
  end

  def set_incomplete_match_day
    @match_day_is_complete = false
    @end_of_match_day_standings = nil
  end

  def extract_team_and_score(result)
    result.match(RESULT_REGEX).named_captures
  end

  def update_standings(team_name, result_type)
    processed_standings[team_name] += POINTS[result_type]
  end
end
