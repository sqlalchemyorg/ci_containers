#!/bin/sh

# --extra-vars force_container_rebuild=true

ansible-playbook \
	-vv -i hosts \
        -e @config.yml \
        -e @.secrets.yml \
    $1 $2 $3 $4 $5 $6 $7 $8 $9 \
	site.yml
