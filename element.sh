#!/bin/bash

# Define the PSQL variable
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    echo "Please provide an element as an argument."
else
    # Store the first argument as element_id
    element_id=$1

    # Check if element_id is numeric
    if [[ $element_id =~ ^[0-9]+$ ]]; then
        # element_id is numeric, query by atomic_number
        query="SELECT * FROM elements JOIN properties USING(atomic_number) WHERE atomic_number = $element_id"
    else
        # element_id is not numeric, query by symbol or name (case-insensitive)
        query="SELECT * FROM elements JOIN properties USING(atomic_number) WHERE symbol = '$element_id' OR name = '$element_id'"
    fi

    # Execute the query
    result=$($PSQL "$query")

    if [ -z "$result" ]; then
        echo "I could not find that element in the database."
    else
        IFS='|' read -r atomic_number symbol name category atomic_mass melting_point boiling_point type_id <<< "$result"
        echo "The element with atomic number $atomic_number is $name ($symbol). It's a $category, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    fi
fi
