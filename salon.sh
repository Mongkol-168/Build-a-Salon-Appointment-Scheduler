#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

# Show the service list and keep asking until a valid service_id is chosen
CHOOSE_SERVICE() {
  while true
  do
    # Print each service as "service_id) name"
    $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED

    # Must be a number, and must exist in the services table
    if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -n $SERVICE_NAME ]]
      then
        break
      fi
    fi

    echo -e "\nI could not find that service. What would you like today?"
  done
}

CHOOSE_SERVICE

# Ask for the phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Look up the customer by phone number
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If they are not a customer yet, ask for their name and add them
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  SAFE_NAME=${CUSTOMER_NAME//\'/\'\'}
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$SAFE_NAME', '$CUSTOMER_PHONE')")
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Ask for the appointment time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Create the appointment
SAFE_TIME=${SERVICE_TIME//\'/\'\'}
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SAFE_TIME')")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
