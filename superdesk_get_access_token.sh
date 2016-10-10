#!/bin/sh

#host="http://localhost:5050/oauth/token"
host="http://api.master.dev.superdesk.org/oauth/token"
#host="http://api.gce.superdesk.org/oauth/token"
client_id="client1_id"
grant_type="password"
username="client1_user"
password="password"

curl -k -X POST -d "client_id=$client_id&grant_type=$grant_type&username=$username&password=$password" "$host"
