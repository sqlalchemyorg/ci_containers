=============
ci_containers
=============

Builds out a Jenkins build-follower for SQLAlchemy and related projects.

The Jenkins that runs at http://jenkins.sqlalchemy.org is only the front
end jenkins servers and no jobs are actually run.  The jobs are run
on remote build-followers that run in a private network.  These machines
call-in to the Jenkins server that's exposed publicly.

A build follower basically contains lots of Python builds as well
as running instances of all the major databases we test on.  The databases
are running in Docker containers::

	[classic@dell ~]$ sudo docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Ports}}\t{{.Names}}"
	CONTAINER ID        IMAGE               PORTS                                                        NAMES
	af61f4b6d9f4        mssql_2017          192.168.1.208:1433->1433/tcp                                 mssql_2017
	2a0ffcfb23bb        mariadb_10.1.24     192.168.1.204:3306->3306/tcp                                 mariadb_10.1.24
	c0548ccc0f18        mariadb_10.2.9      192.168.1.203:3306->3306/tcp                                 mariadb_10.2.9
	d8bd8a83cde8        mysql_5.6           192.168.1.202:3306->3306/tcp                                 mysql_5.6
	00426728f505        mysql_5.7           192.168.1.201:3306->3306/tcp                                 mysql_5.7
	e024673df0b6        postgresql_9.4      192.168.1.207:5432->5432/tcp                                 postgresql_9.4
	c48927ea483d        postgresql_9.6      192.168.1.206:5432->5432/tcp                                 postgresql_9.6
	36dc50aec4d3        postgresql_10       192.168.1.209:5432->5432/tcp                                 postgresql_10
	0ccc4cc4bcf9        oracle_11.2.0       192.168.1.205:1521->1521/tcp, 192.168.1.205:8085->8085/tcp   oracle_11.2.0

The Docker containers are all custom and work the same way.   The Oracle and
MSSQL containers are the most elaborate.