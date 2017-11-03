Configuration server
====================

This repository contains the Spring Cloud Config Server, to provide centralised configuration for all service (betting, cashflow...) properties, in all environments (local, dev1, test1, prod...).

**Local installation without changing configuration properties**

If you're not changing any properties, then you should just use the default configuration on the service. Usually, each service has a configuration that should look similar to this:

```yaml
configServer:
  baseUrl: [url-config-server]
  token: [token-for-kong]
spring:
  application:
    name: [application-name]
  cloud:
    config:
      token: ${configServer.token}
      uri: ${configServer.baseUrl}
  profiles:
    active: [spring-active-profile]
```

The `configServer.baseUrl` property is the one used on start-up to load the properties for the specified active profile (by default, local).

If you want to check your service information, you can always query:

`curl --header "X-Config-Token: 8e1839f23ae74e84a4e5e4edf999a0bb" http://config-server.coral-epos2.co.uk/[application-name]-[spring-active-profile].[properties|yml]`

For example:

`curl --header "X-Config-Token: 8e1839f23ae74e84a4e5e4edf999a0bb" http://config-server.coral-epos2.co.uk/betting-local.properties`

The header `X-Config-Token` is needed for security restrictions.

**Local installation changing configuration properties**

If you're planning to change / add properties to the configuration service, you probably need to test them first, before pushing.

In order to do that, you can just run the configuration server locally, by following these steps:

1. Clone the [configuration properties repository](https://bitbucket.org/coralpoc/configuration-properties) somewhere in your filesystem.
2. Change the `rootPath` property on this (configuration server) repository to the location of the repository you cloned on step 1 (default one is: `/opt/configuration-properties`)
3. Under the root directory of this project (configuration server), run `mvn spring-boot:run`
4. Change your service (betting, cashflow...) `configServer.baseUrl` endpoint to your local host

**Encrypting/Decrypting properties**

From the endpoint we mentioned before (for example: `http://config-server.coral-epos2.co.uk/betting-local.properties`)
properties are exposed with their actual values, but in the configuration-properties repository you may see some properties following this pattern: `{cipher}XXXX`.
Those properties are encrypted in the codebase, and are decrypted using a key by the configuration server.

So, if you have a property that you think should be hidden from the codebase (password, secrets...), you can use endpoints provided by Spring Cloud Config Server. In order to do that, make sure you start the server like this: `mvn spring-boot:run -Dencrypt.key=[encryption-key]`.

Also, you'll need to install the [Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy for Oracle JDK](http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html).

You'll need to copy the two files (replacing if necessary) inside the downloaded zip to `$JAVA_HOME/lib/security`, and restart any Java process to take the changes. If you're using Mac, usually the folder would be in: `/Library/Java/JavaVirtualMachines/jdk[1.8.X]/Contents/Home/jre/lib/security`, but of course it depends on your specific installation.

The encryption key will depend on the environment you're working on. You need to have a look at the infrastructure repository: `coral-epos2-infrastructure/ssh/keys/config-server/` for more information.

For additional information about how to do encryption and decryption of data (you can actually use an HTTP endpoint provided by Spring Cloud Config Server), visit the [official documentation](https://cloud.spring.io/spring-cloud-config/spring-cloud-config.html#_encryption_and_decryption).
