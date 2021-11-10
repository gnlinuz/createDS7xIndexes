# Use this script to create indexes and rebuild them
#
# Created on 09/Nov/2021
# Author = G.Nikolaidis
# Version 1.0.0

# Create --set index-type:equality indexes and rebuild them with default values
# --set index-entry-limit:4000
#

# Start
#
clear


# Settings
# you can change the below settings to meet your installation requirments
#
OPENDJ=/opt/ds702Replication1/opendj
FQDN=localhost
ADMINPORT=5444
SSLPORT=2636
BIND="uid=admin"
BINDPASSWORD=Password1
BACKENDNAME=exampleOrgBackend
INDEXTYPE=equality
INDEXENTRYLIMIT=4000
BASEDN=dc=example,dc=org
# add or remove indexes to be created, index-type:equality
# if other type of indexes needed better add a new loop
#
INDEXES=("cn" "mail" "ds-certificate-subject-dn" "ds-certificate-fingerprint" "uid")


# --index-name description \
# --set index-type:equality \
# --set index-entry-limit:4000 \


# creating indexes
#
printf "start creating indexes..."
echo
echo
for i in ${INDEXES[@]}; do
  printf "creting $i index..."
  $OPENDJ/bin/./dsconfig create-backend-index \
  --backend-name $BACKENDNAME \
  --set index-type:$INDEXTYPE \
  --set index-entry-limit:$INDEXENTRYLIMIT
  --type generic \
  --index-name $i \
  --hostname $FQDN \
  --port $ADMINPORT \
  --bindDn $BIND \
  --trustAll \
  --bindPassword $BINDPASSWORD \
  --no-prompt
  if [ $? -ne 0 ]; then
        printf "Creating index failed"
        exit -1
  fi
  echo
done

echo


# rebuild all the indexes
#
printf "start rebuilding indexes..."
echo
echo
for n in ${INDEXES[@]}; do
  echo
  printf "rebuilding $n index..."
  echo
  $OPENDJ/bin/./rebuild-index \
  --hostname $FQDN \
  --port $ADMINPORT \
  --bindDN $BIND \
  --bindPassword $BINDPASSWORD \
  --baseDN $BASEDN \
  --index $n \
  --usePkcs12TrustStore $OPENDJ/config/keystore \
  --trustStorePasswordFile $OPENDJ/config/keystore.pin
done
# --rebuildDegraded \
echo
echo
printf "Finished creating and rebuilding indexes..."
echo

# END
