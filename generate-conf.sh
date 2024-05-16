#!/bin/bash

# Check if the environment parameter is passed
if [ -z "$1" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

ENVIRONMENT=$1

# Filenames
TEMPLATE_FILE="confTemplate.tfvars"
DEFAULT_VALUES_FILE="defaultValues.json"
KEY_MAPPINGS_FILE="keyMappings.json"
OUTPUT_FILE="conf.auto.tfvars"

# Check if the required files exist
if [ ! -f "$TEMPLATE_FILE" ] || [ ! -f "$DEFAULT_VALUES_FILE" ] || [ ! -f "$KEY_MAPPINGS_FILE" ]; then
    echo "Required file(s) not found!"
    echo "Following are the missing files:"
    [ ! -f "$TEMPLATE_FILE" ] && echo "$TEMPLATE_FILE"
    [ ! -f "$DEFAULT_VALUES_FILE" ] && echo "$DEFAULT_VALUES_FILE"
    [ ! -f "$KEY_MAPPINGS_FILE" ] && echo "$KEY_MAPPINGS_FILE"
    exit 1
fi

# Create an empty output file
> $OUTPUT_FILE

# Read the template file to get the keys
TEMPLATE_KEYS=$(grep -oP '^\s*\K\w+' $TEMPLATE_FILE)

# Iterate over each key and map to the appropriate value
for KEY in $TEMPLATE_KEYS; do
    # Get the corresponding key in the key mappings file for the environment
    MAPPED_KEY=$(jq -r --arg env "$ENVIRONMENT" --arg key "$KEY" '.[$env][$key]' $KEY_MAPPINGS_FILE)
    
    if [ "$MAPPED_KEY" == "null" ]; then
        echo "Mapping for key $KEY not found in $KEY_MAPPINGS_FILE for environment $ENVIRONMENT"
        continue
    fi
    
    # Get the value for the original key from the default values file
    VALUE=$(jq -r --arg env "$ENVIRONMENT" --arg key "$KEY" '.[$env][$key]' $DEFAULT_VALUES_FILE)
    
    if [ "$VALUE" == "null" ]; then
        echo "Value for key $KEY not found in $DEFAULT_VALUES_FILE for environment $ENVIRONMENT"
        continue
    fi
    
    # Write the mapped key-value pair to the output file
    echo "$MAPPED_KEY = \"$VALUE\"" >> $OUTPUT_FILE
done

echo "Configuration file $OUTPUT_FILE generated successfully."
