# Soccer League Results Calculator

## Dependencies
- Ruby 3.2.1

## Instructions

### Installation
- Run `bundle install` or ensure you have the `rspec` gem installed in order to run the unit tests included in the `spec/` folder.
- Ensure that the correct permissions are set on `bin/league-data-handler.rb` to allow it to run as an executable file.

### Running the Application
- The application can take input provided via stdin or as file path, and the following commands should be run from the application root directory
  - stdin example: `cat sample-input.txt | bin/league-data-handler.rb`
  - file example: `bin/league-data-handler.rb sample-input.txt`

### Running the Automated Tests
- The suite of RSpec tests can be run from the application root directory with this command: `rspec spec`

### Design Notes
- This application separates the work of calculating soccer league results into two parts: data I/O, and tracking match results
- The data I/O portion of the application is fairly straight-forward, relying on Ruby's ARGF to accept input from either stdin or a filename and direct each line of match data toward the object that will calculate and persist league results
- The league standing object persists two main buckets of data: one, tracking the number of games played per team, and two, tracking the number of points awarded by match result per team
- The number of games played per team is used to detect when a match day has ended--when a complete match day is detected, the object exposes that state through a boolean method, and also exposes the league standings as a hash to the calling I/O object. In an intermediate state or when the match day is not complete, the boolean method reflects that state and the end-of-match-day league standings are not available to outside calling objects.
- Finally, an 'END' code is used to ensure that valid end-of-day league standings are printed as long as the match day has been completed with each team having an equal number of games played.
