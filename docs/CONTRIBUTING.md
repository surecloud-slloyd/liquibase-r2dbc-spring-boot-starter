# Welcome to contributing developer guide
Feel free to contribute! Create a fork or report bug to improve this project

## Build and test

```bash
./mvnw clean ; ./mvnw verify
```

## Integration test (H2 file)

```bash
rm -rf ~/.m2/repository/daggerok/liquibase/r2dbc* 
./mvnw clean install -DskipTests

./mvnw -f examples/h2/file spring-boot:start

http :8003
http :8003/api
http :8003/api/messages
http :8003/api/messages body=hey
http :8003/api/messages

./mvnw -f examples/h2/file spring-boot:stop
```

## Integration test (H2 mem)

```bash
rm -rf ~/.m2/repository/daggerok/liquibase/r2dbc* 
./mvnw clean install -DskipTests

./mvnw -f examples/h2/mem spring-boot:start

http :8004
http :8004/api
http :8004/api/messages
http :8004/api/messages body=hey
http :8004/api/messages

./mvnw -f examples/h2/mem spring-boot:stop
```

## Integration test (MySQL)

```bash
if [[ "" != `docker ps -aq` ]] ; then docker rm -f -v `docker ps -aq` ; fi

docker run -d --rm --name mysql --platform=linux/x86_64 \
  --health-cmd='mysqladmin ping -h 127.0.0.1 -u $MYSQL_USER --password=$MYSQL_PASSWORD || exit 1' \
  --health-start-period=1s --health-retries=1111 --health-interval=1s --health-timeout=5s \
  -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=database \
  -e MYSQL_USER=user -e MYSQL_PASSWORD=password \
  -p 3306:3306 \
  mysql:8.0.24

while [[ $(docker ps -n 1 -q -f health=healthy -f status=running | wc -l) -lt 1 ]] ; do
  sleep 3 ; echo -n '.'
done

sleep 15; echo 'MySQL is ready.'

rm -rf ~/.m2/repository/daggerok/liquibase/r2dbc* 
./mvnw clean install -DskipTests

./mvnw -f examples/mysql spring-boot:start

http :8001
http :8001/api
http :8001/api/messages
http :8001/api/messages body=hey
http :8001/api/messages

./mvnw -f examples/mysql spring-boot:stop
docker stop mysql
```

## Integration test (Postgresql)

```bash
if [[ "" != `docker ps -aq` ]] ; then docker rm -f -v `docker ps -aq` ; fi

docker run -d --rm --name postgres -p 5432:5432 --platform=linux/x86_64 \
  -e POSTGRES_PASSWORD=password -e POSTGRES_DB=database -e POSTGRES_USER=user \
  --health-start-period=1s --health-retries=1111 --health-interval=1s --health-timeout=5s \
  --health-cmd='pg_isready -h 127.0.0.1 -p 5432 -d $POSTGRES_DB -U $POSTGRES_USER || exit 1' \
  postgres:14.3-alpine3.16

while [[ $(docker ps -n 1 -q -f health=healthy -f status=running | wc -l) -lt 1 ]] ; do
  sleep 3 ; echo -n '.'
done

rm -rf ~/.m2/repository/daggerok/liquibase/r2dbc* 
./mvnw clean install -DskipTests

./mvnw -f examples/postgresql spring-boot:start

http :8002
http :8002/api
http :8002/api/messages
http :8002/api/messages body=hey
http :8002/api/messages

./mvnw -f examples/postgresql spring-boot:stop
docker stop postgres
```

## Integration test (MariaDB)

```bash
if [[ "" != `docker ps -aq` ]] ; then docker rm -f -v `docker ps -aq` ; fi

docker run -p 3306:3306 -d --rm --name mariadb --platform=linux/x86_64 \
  --env MARIADB_USER=user --env MARIADB_PASSWORD=password --env MARIADB_ROOT_PASSWORD=password --env MARIADB_DATABASE=database \
  --health-cmd='mysqladmin ping -h 127.0.0.1 -u $MARIADB_USER --password=$MARIADB_PASSWORD || exit 1' \
  --health-start-period=1s --health-retries=1111 --health-interval=1s --health-timeout=5s \
  mariadb:10.7.4

while [[ $(docker ps -n 1 -q -f health=healthy -f status=running | wc -l) -lt 1 ]] ; do
  sleep 3 ; echo -n '.'
done
echo 'MariaDB is ready.'

rm -rf ~/.m2/repository/daggerok/liquibase/r2dbc* 
./mvnw clean install -DskipTests

./mvnw -f examples/mariadb spring-boot:start

http :8005
http :8005/api
http :8005/api/messages
http :8005/api/messages body=hey
http :8005/api/messages

./mvnw -f examples/mariadb spring-boot:stop
```

<!--

### Set maven versions

1.0.5 -> 1.1.0-SNAPSHOT

```bash
./mvnw build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.nextMinorVersion}.0-SNAPSHOT
./mvnw build-helper:parse-version versions:commit
./mvnw clean ; ./mvnw -U
git add .
git commit -am "..."
```

### JDK

```bash
brew reinstall temurin17 
```

### GPG

Installing GnuPG:

```bash
brew reinstall gpg
```

Verify:

```bash
gpg --version
```

Generating a Key Pair:

```bash
gpg --gen-key

#Real name: Maksim Kostromin

#Email address: daggerok@gmail.com

#Enter passphrase: Enter and confirm your gpg passphrase...
#Remember it. This passphrase and your private key are all
#that is needed to sign artifacts with your signature
```

List keys:

```bash
gpg --list-keys
#Output:
#gpg: checking the trustdb
#gpg: marginals needed: 3  completes needed: 1  trust model: pgp
#gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
#gpg: next trustdb check due at 2024-06-01
#/Users/maksim.kostromin/.gnupg/pubring.kbx
#------------------------------------------
#pub   ed25519 2022-06-02 [SC] [expires: 2024-06-01]
#      7F8C9950CBD5506E6C69A839FB201BAC2CDB5B17
#uid           [ultimate] Maksim Kostromin <daggerok@gmail.com>
#sub   cv25519 2022-06-02 [E] [expires: 2024-06-01]
```

Sent key:

```bash
gpg --keyserver hkps://keys.openpgp.org --send-keys 7F8C9950CBD5506E6C69A839FB201BAC2CDB5B17
```

Export key:

```bash
gpg -a --export-secret-keys 7F8C9950CBD5506E6C69A839FB201BAC2CDB5B17
#Output:
#-----BEGIN PGP PRIVATE KEY BLOCK-----
#...
#-----END PGP PRIVATE KEY BLOCK-----
```

### Maven

TODO...

```bash
echo '
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.1.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 https://maven.apache.org/xsd/settings-1.1.0.xsd">
  <servers>
    <server>
      <id>ossrh</id>
      <username>Sonatype username...</username>
      <password>Sonatype password...</password>
    </server>
  </servers>
</settings>
' > ~/.m2/settings.xml
```

### Reference Documentation

Useful links:
* [GPG](https://central.sonatype.org/publish/requirements/gpg/)
* [Maven Deploy](https://central.sonatype.org/publish/publish-maven/)
* https://www.mojohaus.org/versions-maven-plugin/examples/set.html
* https://central.sonatype.org/publish/requirements/coordinates/
* https://issues.sonatype.org/browse/OSSRH-81403
* https://issues.sonatype.org/browse/OSSRH-81403?focusedCommentId=1172647&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-1172647
* https://central.sonatype.org/publish/publish-guide/#deployment
* https://github.com/samuelmeuli/action-maven-publish
* https://github.com/samuelmeuli/action-maven-publish/blob/master/docs/deployment-setup.md#project-configuration
* https://github.community/t/combine-path-and-tags-conditionals/17064
* https://central.sonatype.org/publish/release/
* https://help.sonatype.com/lift/configuring-lift
* https://lift.sonatype.com/results/github.com/daggerok
* https://help.sonatype.com/repomanager2/staging-releases/configuring-your-project-for-deployment
* https://central.sonatype.org/publish/publish-maven/#gpg-signed-components
* https://v2.vuepress.vuejs.org/guide/getting-started.html
* https://github.com/actions/setup-java
* https://mariadb.com/resources/blog/unblock-your-applications-with-r2dbc-spring-data-and-mariadb/
* https://xenovation.com/blog/development/java/java-professional-developer/liquibase-related-sql-java-types
* https://github.com/r2dbc/r2dbc-h2
* https://www.youtube.com/watch?v=7rTs3e79sDo
* https://mariadb.com/docs/connect/programming-languages/java-r2dbc/spring/
* https://hub.docker.com/_/mariadb
* https://stackoverflow.com/questions/68069403/r2dbc-illegalargumentexception-cannot-encode-parameter-of-type-java-util-date/71917628#71917628

For further reference, please consider the following sections:

* [Official Apache Maven documentation](https://maven.apache.org/guides/index.html)
* [Spring Boot Maven Plugin Reference Guide](https://docs.spring.io/spring-boot/docs/2.7.0/maven-plugin/reference/html/)
* [Create an OCI image](https://docs.spring.io/spring-boot/docs/2.7.0/maven-plugin/reference/html/#build-image)
* [Testcontainers R2DBC support Reference Guide](https://www.testcontainers.org/modules/databases/r2dbc/)
* [Testcontainers MySQL Module Reference Guide](https://www.testcontainers.org/modules/databases/mysql/)
* [Coroutines section of the Spring Framework Documentation](https://docs.spring.io/spring/docs/5.3.20/spring-framework-reference/languages.html#coroutines)
* [Liquibase Migration](https://docs.spring.io/spring-boot/docs/2.7.0/reference/htmlsingle/#howto.data-initialization.migration-tool.liquibase)
* [Spring Configuration Processor](https://docs.spring.io/spring-boot/docs/2.7.0/reference/htmlsingle/#appendix.configuration-metadata.annotation-processor)
* [Spring Data R2DBC](https://docs.spring.io/spring-boot/docs/2.7.0/reference/htmlsingle/#data.sql.r2dbc)
* [Testcontainers](https://www.testcontainers.org/)

### Guides

The following guides illustrate how to use some features concretely:

* [Acessing data with R2DBC](https://spring.io/guides/gs/accessing-data-r2dbc/)
* [Accessing data with MySQL](https://spring.io/guides/gs/accessing-data-mysql/)

### Additional Links

These additional references should also help you:

* [R2DBC Homepage](https://r2dbc.io)

## Missing R2DBC Driver

Make sure to include a [R2DBC Driver](https://r2dbc.io/drivers/) to connect to your database.

-->
