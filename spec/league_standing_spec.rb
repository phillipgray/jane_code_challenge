require_relative '../lib/league_standing'

RSpec.describe LeagueStanding do
  subject(:standing) { described_class.new }

  describe '#games_played' do
    context 'when there are no games played/processed' do
      it 'returns an empty summary hash' do
        expect(standing.games_played).to eq({})
      end
    end
  end

  describe '#processed_standings' do
    context 'when there are no games played/processed' do
      it 'returns an empty summary hash' do
        expect(standing.processed_standings).to eq({})
      end
    end
  end

  describe '#match_day_is_complete?' do
    context 'after processing matches without end code or next day matches' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
      end

      it 'returns false' do
        expect(standing.match_day_complete?).to eq(false)
      end
    end

    context 'after processing a partial match day plus end code' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
        standing.process_match('C 0, B 0')
        standing.process_match('END')
      end

      it 'returns false' do
        expect(standing.match_day_complete?).to eq(false)
      end
    end

    context 'after processing a full match day plus one match' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
        standing.process_match('C 0, B 0')
      end

      it 'returns true' do
        expect(standing.match_day_complete?).to eq(true)
      end
    end

    context 'after processing a full match day plus end code' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
        standing.process_match('END')
      end

      it 'returns true' do
        expect(standing.match_day_complete?).to eq(true)
      end
    end
  end

  describe '#end_of_match_day_standings' do
    context 'after processing matches without end code or next day matches' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
      end

      it 'returns nil' do
        expect(standing.end_of_match_day_standings(limit: 1)).to be_nil
      end
    end

    context 'after processing a partial match day plus end code' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
        standing.process_match('C 0, B 0')
        standing.process_match('END')
      end

      it 'returns nil' do
        expect(standing.end_of_match_day_standings).to be_nil
      end
    end

    context 'after processing a full match day plus one match' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
        standing.process_match('C 0, B 0')
      end

      it 'returns the expected standings' do
        expected_eod_standings = {
          'B' => 3,
          'C' => 3,
          'E' => 1,
          'F' => 1,
          'A' => 0,
          'D' => 0
        }
        expect(standing.end_of_match_day_standings).to eq(expected_eod_standings)
      end

      context 'when a limit is specified' do
        it 'returns the expected standings' do
          expected_eod_standings = {
            'B' => 3,
            'C' => 3,
            'E' => 1
          }
          expect(standing.end_of_match_day_standings(limit: 3))
            .to eq(expected_eod_standings)
        end
      end
    end

    context 'after processing a full match day plus end code' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
        standing.process_match('END')
      end

      it 'returns true' do
        expected_eod_standings = {
            'B' => 3,
            'C' => 3,
            'E' => 1,
            'F' => 1
        }

        expect(standing.end_of_match_day_standings(limit: 4))
          .to eq(expected_eod_standings)
      end
    end
  end

  describe '#process_match' do
    context 'with valid match text' do
      it 'returns valid_text' do
        expect(standing.process_match('A 2, B 3')).to eq(:valid_text)
      end
    end

    context 'with end code' do
      it 'returns valid_text' do
        expect(standing.process_match('END')).to eq(:valid_text)
      end
    end

    context 'with invalid match text' do
      it 'returns invalid_text without processing' do
        aggregate_failures do
          expect(standing.process_match('bananas foster')).to eq(:invalid_text)
          expect(standing.games_played).to be_empty
          expect(standing.processed_standings).to be_empty
        end
      end
    end

    context 'after processing a single match' do
      before { standing.process_match('A 2, B 3') }

      it 'updates the stored games_played' do
        expect(standing.games_played).to eq('A' => 1, 'B' => 1)
      end

      it 'updates the stored processed standings' do
        expect(standing.processed_standings).to eq('B' => 3, 'A' => 0)
      end
    end

    context 'after processing multiple matches' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
      end

      it 'updates the stored games played' do
        expected_games = {
          'A' => 1,
          'B' => 1,
          'C' => 1,
          'D' => 1,
          'E' => 1,
          'F' => 1
        }

        expect(standing.games_played).to eq(expected_games)
      end

      it 'updates the stored processed standings' do
        expected_standings = {
          'B' => 3,
          'C' => 3,
          'E' => 1,
          'F' => 1,
          'A' => 0,
          'D' => 0
        }
        expect(standing.processed_standings).to eq(expected_standings)
      end
    end

    context 'after processing a full match day plus one match' do
      before do
        standing.process_match('A 2, B 3')
        standing.process_match('C 3, D 1')
        standing.process_match('E 0, F 0')
        standing.process_match('C 0, B 0')
      end

      it 'updates the stored games played' do
        expected_games = {
          'A' => 1,
          'B' => 2,
          'C' => 2,
          'D' => 1,
          'E' => 1,
          'F' => 1
        }

        expect(standing.games_played).to eq(expected_games)
      end

      it 'updates the stored standings' do
        expected_standings = {
          'B' => 4,
          'C' => 4,
          'E' => 1,
          'F' => 1,
          'A' => 0,
          'D' => 0
        }
        expect(standing.processed_standings).to eq(expected_standings)
      end
    end
  end
end
