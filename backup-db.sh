#! /bin/sh

set -eo pipefail

if [ "${AZURE_TENANT_ID}" = "" ]; then
  echo "You need to set the AZURE_TENANT_ID environment variable."
  exit 1
fi

if [ "${AZURE_APP_ID}" = "" ]; then
  echo "You need to set the AZURE_APP_ID environment variable."
  exit 1
fi

if [ "${AZURE_SECRET_ID}" = "" ]; then
  echo "You need to set the AZURE_SECRET_ID environment variable."
  exit 1
fi

if [ "${AZURE_STORAGE_ACCOUNT}" = "" ]; then
  echo "You need to set the AZURE_STORAGE_ACCOUNT environment variable."
  exit 1
fi

if [ "${AZURE_STORAGE_CONTAINER}" = "" ]; then
  echo "You need to set the AZURE_STORAGE_CONTAINER environment variable."
  exit 1
fi

if [ "${AZURE_STORAGE_ACCESS_KEY}" = "" ]; then
  echo "You need to set the $AZURE_STORAGE_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${POSTGRES_DATABASE}" = "" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "" ]; then
  echo "You need to set the POSTGRES_HOST environment variable."
  exit 1
fi

if [ "${POSTGRES_PORT}" = "" ]; then
  echo "You need to set the POSTGRES_HOST environment variable."
  exit 1
fi

if [ "${POSTGRES_USER}" = "" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "" ] && [ "${POSTGRES_HOST}" != "localhost" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

if [ "${TEMPORARY_FOLDER_PATH}" = "" ]; then
  echo "You need to set the TEMPORARY_FOLDER_PATH in order to store the temporary files."
  exit 1
fi

# export ENV vars for azstorage container
export AZURE_STORAGE_ACCOUNT="$AZURE_STORAGE_ACCOUNT"
export AZURE_STORAGE_ACCESS_KEY="$AZURE_STORAGE_ACCESS_KEY"

echo $POSTGRES_PASSWORD

export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-v -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"

echo "\nCreating dump of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."

pg_dump $POSTGRES_HOST_OPTS $POSTGRES_DATABASE -f $TEMPORARY_FOLDER_PATH/dump-postgres.bak && gzip -c $TEMPORARY_FOLDER_PATH/dump-postgres.bak > $TEMPORARY_FOLDER_PATH/dump.sql.gz

echo "\nlogging into Azure cloud account"

az login \
  --service-principal \
  --user $AZURE_APP_ID \
  --password $AZURE_SECRET_ID \
  --tenant $AZURE_TENANT_ID \
  --allow-no-subscriptions

echo "Uploading dump to $AZURE_STORAGE_CONTAINER"

az storage container create \
	--name $AZURE_STORAGE_CONTAINER \
	--account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_ACCESS_KEY

az storage blob upload \
  --container-name $AZURE_STORAGE_CONTAINER \
  --account-name $AZURE_STORAGE_ACCOUNT --account-key $AZURE_STORAGE_ACCESS_KEY \
  --name ${POSTGRES_DATABASE}_$(date +"%Y-%m-%dT%H:%M:%SZ").sql.gz \
  --file $TEMPORARY_FOLDER_PATH/dump.sql.gz

rm -f $TEMPORARY_FOLDER_PATH/dump-postgres.bak
rm -f $TEMPORARY_FOLDER_PATH/dump.sql.gz

echo "SQL backup uploaded successfully"