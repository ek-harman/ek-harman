#!/usr/bin/env bash

# OpenSSL requires the port number.
SERVER=$1
FILTER=$2
DELAY=1

if [ -z "${FILTER}" ]; then
    echo "No Filter was set"
    ciphers=$(openssl ciphers -v 'ALL:eNULL' | awk '{print$1}' )
else
   echo "Filtering [ $FILTER ] "
   ciphers=$(openssl ciphers -v 'ALL:eNULL' | grep $FILTER |awk '{print$1}' )
fi
#ciphers=$(openssl ciphers 'ALL:eNULL' | grep $FILTER | sed -e 's/:/ /g')

echo Obtaining cipher list from $(openssl version).

for cipher in ${ciphers[@]}
do
  echo -n Testing $cipher...
  result=$(echo -n | openssl s_client -cipher "$cipher" -connect $SERVER 2>&1)
  if [[ "$result" =~ ":error:" ]] ; then
    error=$(echo -n $result | cut -d':' -f6)
    echo NO \($error\)
  else
    if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    :" ]] ; then
      echo YES
    else
      echo UNKNOWN RESPONSE
      echo $result
    fi
  fi
  sleep $DELAY
done
