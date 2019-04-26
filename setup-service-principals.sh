#!/bin/bash -e

USER="http://aks-admin-user"
SA_NAME="ts00tfstatesa"
SA_KEY=${SA_KEY:-}
SA_TF_CONTAINER_NAME="tfstate"

az ad sp show --id $USER 1>/dev/null

if [ $? != 0 ]; then
    echo 'Creating a new Service Principal to manage aks cluster creation...'
    az ad sp create-for-rbac --name $USER
fi

az storage container exists --name $SA_TF_CONTAINER_NAME --account-name $SA_NAME --account-key "${SA_KEY}" 1>/dev/null

if [ $? != 0 ]; then
    echo 'Creating a storage account to store .tfstate file...'
    az storage container create -n $SA_TF_CONTAINER_NAME --account-name $SA_NAME --account-key "${SA_KEY}"

    terraform init -backend-config="storage_account_name=${SA_NAME}" -backend-config="container_name=${SA_TF_CONTAINER_NAME}" -backend-config="access_key=${SA_KEY}" -backend-config="key=refk8s.tfstate"
fi
