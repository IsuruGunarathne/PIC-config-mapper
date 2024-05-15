#!/bin/bash

# Check if environment parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <environment>"
  exit 1
fi

ENVIRONMENT=$1

# Define the values for each environment
case $ENVIRONMENT in
  dev)
    VAR1="dev_value1"
    VAR2="dev_value2"
    VAR3="dev_value3"
    ;;
  prod)
    VAR1="prod_value1"
    VAR2="prod_value2"
    VAR3="prod_value3"
    ;;
  staging)
    VAR1="staging_value1"
    VAR2="staging_value2"
    VAR3="staging_value3"
    ;;
  *)
    echo "Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

# Read the template file and replace placeholders
TEMPLATE_FILE="confTemplate.tfvars"
OUTPUT_FILE="conf.auto.tfvars"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Template file $TEMPLATE_FILE does not exist."
  exit 1
fi

# Replace placeholders in the template and create the output file
sed -e "s/placeholder1/$VAR1/" \
    -e "s/placeholder2/$VAR2/" \
    -e "s/placeholder3/$VAR3/" \
    $TEMPLATE_FILE > $OUTPUT_FILE

echo "Configuration file $OUTPUT_FILE generated successfully."