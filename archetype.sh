#!/bin/bash

set -e

rm -rf target/archetype

# Get rid of ignored files
git ls-files -c | xargs tar -cf - | (mkdir -p target/archetype && cd $_; tar -xf -)

cd target/archetype

# Change the parent pom to the real starter parent and ensure boot dependencies have a correct groupId
sed -i -e 's,artifactId>spring-boot-samples</artifactId,artifactId>spring-boot-starter-parent</artifactId,' \
    -e 's,groupId>${project.groupId},groupId>org.springframework.boot,' \
    -e 's,version>${project.version},version>${spring-boot.version},' \
    pom.xml

# If only we didn't have to do this...
for d in src/main/java src/test/java; do
    if [ -s $d/sample ]; then
        mkdir $d/tmppackage
        mv $d/sample $d/tmppackage
        find $d -name \*.java | xargs sed -i -e 's/^import sample/import tmppackage.sample/' \
            -e 's/^package sample/package tmppackage.sample/' \
            -e 's/select new sample/select new tmppackage.sample/'
    fi
done
for d in src/main/resources src/test/resources; do
    if [ -s $d ]; then
        args=`find $d -name \*.xml`
        [ -z $args ] || sed -i -e 's/class="sample/class="tmppackage.sample/' $args
    fi
done

mvn archetype:create-from-project -DpackageName=tmppackage.sample

# new archetype is generated here with a unique name
cd target/generated-sources/archetype

# ...or this
find . -name \*.java | xargs sed -i -e 's/^import ${groupId}/import org.springframework.boot/'
sed -i -e 's,/spring-boot-starter-parent/spring-.*</url>,</url>,' pom.xml

# Comment out these two lines to speed it up
mvn package archetype:integration-test
(cd target/test-classes/projects/basic/project/basic; mvn test)