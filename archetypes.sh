#!/bin/bash

set -e

VERSION=1.0.2.RELEASE

if [ -z "${SPRING_HOME}" ]; then
    # Resolve links: $0 may be a link
    PRG="$0"
    # Need this for relative symlinks.
    while [ -h "$PRG" ] ; do
	    ls=`ls -ld "$PRG"`
	    link=`expr "$ls" : '.*-> \(.*\)$'`
	    if expr "$link" : '/.*' > /dev/null; then
		    PRG="$link"
	    else
		    PRG=`dirname "$PRG"`"/$link"
	    fi
    done
    SAVED="`pwd`"
    cd "`dirname \"$PRG\"`/boot/" >&-
    SPRING_HOME="`pwd -P`"
    cd "$SAVED" >&-
fi

mkdir -p ${SPRING_HOME}/../archetypes
cd ${SPRING_HOME}/../archetypes
cp ../template-pom.xml pom.xml

function archetype() {

    # The name of the sample (e.g. simple, data-jpa)
    sample=${1}

    base=${SPRING_HOME}/spring-boot-samples/spring-boot-sample-${sample}

    (cd ${base}; ${SPRING_HOME}/../archetype.sh)

    rm -rf sample-*

    modules="<modules>"
    name=${base##*/spring-boot-}
    mkdir -p ${name}
    cp -rf ${SPRING_HOME}/spring-boot-samples/spring-boot-${name}/target/archetype/target/generated-sources/archetype/* ${name}
    modules=${modules}"<module>"${name}"</module></modules>"

    sed -i -e "s,<modules>.*</modules>,$modules," pom.xml
    sed -i -e "s,>[^<]*</version></parent>,>${VERSION}</version></parent>," pom.xml
    sed -i -e "s,</modelVersion>,</modelVersion>\n  <parent><groupId>org.springframework.boot</groupId><artifactId>spring-boot-archetypes</artifactId><version>$VERSION</version></parent>," ${name}/pom.xml

    mvn deploy # -P central

}

if [ -z $1 ]; then
  for f in ${SPRING_HOME}/spring-boot-samples/spring-boot-sample-*; do 
      sample=${f##*sample-}
      # This one has a binary file in it and it doesn't get transferred into the archetype
      if [ ! "$sample" == "tomcat-multi-connectors" ]; then archetype $sample; fi
  done
else
  for f in $*; do archetype $f; done
fi
