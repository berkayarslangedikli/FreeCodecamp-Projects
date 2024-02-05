#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi


echo $($PSQL "TRUNCATE table games, teams")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    TEAM2_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")


    # if not found
    if [[ -z $TEAM_ID ]]
    then
      # insert team into teams
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      # get new major_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    if [[ -z $TEAM2_ID ]]
    then
      # insert major
      INSERT_TEAM2_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM2_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi

      # get new major_id
      TEAM2_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # now insert the current game row into games table using the correct 
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) \
      VALUES('$YEAR', '$ROUND', '$TEAM2_ID', '$TEAM_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    echo this is the insert result: $INSERT_GAME_RESULT
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR $ROUND $TEAM_ID $TEAM2_ID $WINNER_GOALS $OPPONENT_GOALS
      else
        echo insert result is: $INSERT_GAME_RESULT
    fi

  fi
done