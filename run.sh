#!/bin/sh

# rebuild containers and images
# --extra-vars force_container_rebuild=true

# delete containers with docker rm -f
# --extra-vars delete_containers=true, --tags oracle

# delete and relaunch all database containers from existing
# images
# ./run.sh --tags databases --extra-vars delete_containers=true


ansible-playbook \
	-vv -i hosts \
        -e @config.yml \
        -e @.secrets.yml \
    $1 $2 $3 $4 $5 $6 $7 $8 $9 \
	site.yml
