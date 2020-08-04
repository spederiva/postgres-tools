# postgres-tools

Backup Postgres DB from any source to a Azure Storage.

1. Clone this repository
1. cd postgres-tools
1. Run *backup-db.sh* with as in the sample below

```
AZURE_STORAGE_ACCOUNT='<storage account name>' \
AZURE_STORAGE_ACCESS_KEY='<azure storage access key>' \
AZURE_TENANT_ID='<azure tenant id>' \
AZURE_APP_ID='<azure service principle app id>' \
AZURE_SECRET_ID='<azure service principle secret>' \
AZURE_STORAGE_CONTAINER='<azure storage container>' \
POSTGRES_DATABASE='<database name>' \
POSTGRES_HOST='<postgres hostname>' \
POSTGRES_PORT='<postgres hostname, usually 5432>' \
POSTGRES_USER='<postgres db user>' \
POSTGRES_PASSWORD='<postgres db password>' \
./backup-db.sh
```


## Cron Job

If needed a automatic job, crontab can be used. 

Follow the following link in order to install, setup crontab: https://www.digitalocean.com/community/tutorials/how-to-use-cron-to-automate-tasks-ubuntu-1804 or https://www.rosehosting.com/blog/ubuntu-crontab/

## Credit

This image is based on the work by elexy for postgres-backup-restore-azure, which unfortunately is not supported anymore.

