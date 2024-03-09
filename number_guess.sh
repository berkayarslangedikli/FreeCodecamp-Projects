#!/bin/bash

# Define the PSQL variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 100
random_nr=$(( RANDOM % 100 + 1 ))

# Initialize the guess count
guess_count=0

# Prompt the user to enter a username
echo "Please enter your username:"
read username

# Check if the username exists and retrieve user data
user_data=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$username'")

if [[ -z $user_data ]]; then
    # If user does not exist, insert new user and set games_played and best_game
    echo "Welcome, $username! It looks like this is your first time here."
    $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$username', 0, NULL)"
else
    # Parse user data
    IFS='|' read -r returned_username games_played best_game <<< "$user_data"
    echo "Welcome back, $returned_username! You have played $games_played games, and your best game took $best_game guesses."
fi

# Start the guessing game loop
echo "Guess the number between 1 and 100:"
while true; do
    read guess
    if ! [[ $guess =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi
    ((guess_count++))
    guess=$((10#$guess))
    if [ $guess -eq $random_nr ]; then
        echo "Congratulations! You've guessed the number in $guess_count guesses!"
        break
    elif [ $guess -lt $random_nr ]; then
        echo "It's higher than that, guess again:"
    else
        echo "It's lower than that, guess again:"
    fi
done

# Update user data after the game
$PSQL "UPDATE users SET games_played = games_played + 1, best_game = CASE WHEN best_game IS NULL OR best_game > $guess_count THEN $guess_count ELSE best_game END WHERE username = '$username'"
