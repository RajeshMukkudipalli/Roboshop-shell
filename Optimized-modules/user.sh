#!bin/bash

source ./common.sh
app_name=user 
check_root_user
app_setup
node_js_setup
systemd_setup
print_time