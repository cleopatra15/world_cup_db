#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

tail -n +2 "games.csv" | while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  
  # If the query returned empty (-z), the team doesn't exist yet
  if [[ -z $WINNER_ID ]]
  then
    # Insert the team
    $PSQL "INSERT INTO teams(name) VALUES('$winner');"
    # Query the newly generated team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  fi

  # 2. GET OR INSERT OPPONENT TEAM
  # Check if the opponent team is already in the teams table
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
  if [[ -z $OPPONENT_ID ]]
  then
    # Insert the team
    $PSQL "INSERT INTO teams(name) VALUES('$opponent');"
    # Query the newly generated team_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
  fi

  # 3. INSERT THE GAME
  # Now we have both WINNER_ID and OPPONENT_ID, so we can insert the game record
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);"
done
