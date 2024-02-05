#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
LIST_OF_SERVICES=$($PSQL "select * from services")

SHOW_SERVICES() {
  echo -e "\nHere are the services we have available:"
  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}
SHOW_SERVICES
echo "Enter a service id:"
read SERVICE_ID_SELECTED

# get service availability
SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# if not available
if [[ -z $SERVICE_AVAILABILITY ]]
then
  # show same services list again
  SHOW_SERVICES
else
  # get their phone nr
  echo "Enter a phone nr:"
  read CUSTOMER_PHONE
  RESULT_CUSTOMER_SELECT=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if customer doesnt exist
  if [[ -z $RESULT_CUSTOMER_SELECT ]]
  then
    # ask for their name
    echo "Enter your name:"
    read CUSTOMER_NAME
    # enter name and phone nr
    RESULT_INSERT_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  echo "Enter service time:"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  # add the appointment to appointments table
  RESULT_INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ -z $RESULT_INSERT_APPOINTMENT ]]
  then
    echo "Technical error; unable to schedule an appointment"
  else
    SERVICE_SELECTED=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi