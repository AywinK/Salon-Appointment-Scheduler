#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo $1
  fi
  # get available services
  SERVICES=$($PSQL "select * from services;")
  # display available services
  echo -e "\nWhat service would you like?"
    echo $SERVICES | sed 's/([0-9]+) \| ([a-zA-Z]+)/\1) \2\n/g' -E | sed 's/^ //g'
  # get required service
  read SERVICE_ID_SELECTED
  # check if service exists
  SERVICE_ID_SELECTED=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED ]]
    then
      # if not return to main menu and relist services
      MAIN_MENU "Please enter number of service required"
    else
      # else ask for phone number
      echo "Please enter your phone number"
      read CUSTOMER_PHONE
      # get customer name
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
      # if not in database, get name
      if [[ -z $CUSTOMER_NAME ]]
        then
          echo "Please enter your name"
          read CUSTOMER_NAME
          INSERT_CUSTOMER_STATUS=$($PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
      fi
      # get customer id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
      # ask for service time
      echo "What time would you like?,$CUSTOMER_NAME"
      read SERVICE_TIME
      # insert appointment record
      INSERT_APPOINTMENT_STATUS=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      if [[ $INSERT_APPOINTMENT_STATUS == "INSERT 0 1" ]]
        then
          SERVICE_SELECTED=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED;")
          echo I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME.
      fi
  fi
}

  MAIN_MENU