#!/bin/bash

SQL_FILE=$1

[ -f "$SQL_FILE" ] || {
  echo "Please pass a valid SQL dump file"
  exit 1
}

POD_NAME=$(kubectl get pods -l run=postgres -o json | jq '.items[0].metadata.name' | tr -d '"')
kubectl exec -i $POD_NAME -- /bin/bash -c 'cat > /tmp/seed.sql' < $(zcat $SQL_FILE)
kubectl exec -i $POD_NAME -- psql -U orientando -f /tmp/seed.sql
