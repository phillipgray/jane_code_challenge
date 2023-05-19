require_relative './league_standing'

class LeagueDataHandler
  class << self
    def summarize_data
      standings = LeagueStanding.new

      ARGF.each_line do |line|
        process_result = standings.process_match(line.strip)
        next if process_result == :invalid_text

        if standings.match_day_complete?
          print_summary \
            standings.completed_match_day_number,
            standings.end_of_match_day_standings(limit: 3)
        end
      end

      standings.process_match('END')
      if standings.match_day_complete?
        print_summary \
          standings.completed_match_day_number,
          standings.end_of_match_day_standings(limit: 3)
      end
    end

    private

    def print_summary(day_number, summary)
      puts "Matchday #{day_number}"
      summary.each_pair do |team, points|
        puts "#{team}, #{points} #{points > 1 ? 'pts' : 'pt'}"
      end
      print "\n"
    end
  end
end
