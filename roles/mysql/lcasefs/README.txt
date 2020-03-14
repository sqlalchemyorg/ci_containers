this is an unofficial docker build to get a case insensitive filesystem
running in a container to test various MySQL case sensitivity bugs


docker build lcasefs/ -f lcasefs/Dockerfile.mysql  --build-arg "case_insensitive_mysql=1" --build-arg "product_version=8.0.2" --tag lcase_mysql_8


docker run --env MYSQL_VERSION=mysql_8.0.12  --privileged=true lcase_mysql_8
