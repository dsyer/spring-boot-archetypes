Automation scripts for publishing Spring Boot Sample as Maven
archetypes. Manifest:

* `archetypes.sh`: the main driver script. Can be run with no
  arguments, in which case all samples are published, or with an
  explicit list of samples (use the short names, e.g. "data-jpa" for
  "spring-boot-sample-data-jpa").

* `archetype.sh` a helper script that generates the archetype from the
  sample.
  
* `boot` a git submodule pointing at the Spring Boot source code
  
* `archetypes/` a directory created by the driver script as a vehicle
  for the deployment. It acts as an ephemeral parent to a submodule
  which contains the generated archetype, so that the deployment
  metadata can be easily managed.
  
* `template-pom.xml` a template `pom.xml` for the `archetypes/`
  temporary project.
  
* `archetype-catalog.xml` manually maintained catalog of
  artifacts. If you put it in the root of the repository Maven can
  inspect it and propose archetype candidates when you generate a new
  project. Hopefully not necessary in Central, but needs to be
  manually added to the Spring repo.
  
Once they are all deployed you can see them with

```
$ mvn archetype:generate -DarchetypeCatalog=http://repo.spring.io/libs-release-local
```

## Build

* Clone this repo and initialize the submodule
* Checkout the desired release tag in the submodule
* Change the `VERSION` variable in `archetypes.sh`
* Run it, e.g.:

```
# Just publish the simple sample
$ ./archetypes.sh simple
```

The catalog can be pushed to the Spring repo using buildmaster
credentials (add the password):

```
curl -v -u 'buildmaster:\{DESede\}...' -f -d @archetype-catalog.xml -X PUT https://repo.spring.io/libs-release-local/archetype-catalog.xml
```

(See [JFrog JIRA ticket](https://www.jfrog.com/jira/browse/RTFACT-651) for details.)

## Publish to Central

Edit the `archetypes.sh` script and set it to `mvn deploy -P
central`. You will need a PGP key registered with the Sonatype OSS
Nexus.
