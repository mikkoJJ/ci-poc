#####################################################
# * * Example project Spring boot Dockerfile. * *
#####################################################
#
# This Dockerfile will build a spring boot project, unpack the built JAR
# and run it in an openjdk container.
#
# Provide PROXY_OPTS as an argument if your build needs access to the internet
# and is being built in the Cinia infra network (eg. on Jenkins). When building
# on a developer's local machine, PROXY_OPTs shouldn't be used.
#
# Example value for PROXY_OPTS that should work in Cinia infra:
#
# --build-arg PROXY_OPTS='-Dhttp.proxyHost=10.51.145.30 -Dhttps.proxyHost=10.51.145.30 -Dhttp.proxyPort=3128 -Dhttps.proxyPort=3128 -Dhttp.nonProxyHosts=*.ip.cinia.fi

# =======================
# STEP 1: build container
# =======================
FROM library/openjdk:11.0.5-jdk AS build

# Copy sources and settings
WORKDIR /app

# Copy Maven Wrapper
COPY mvnw .
COPY .mvn .mvn

# Preload dependencies, so image never changes unless pom changes aka can be skipped on next build
# May break snapshot updates since pom does not update. Have be careful with those
COPY pom.xml .
RUN ./mvnw dependency:resolve dependency:resolve-plugins --fail-never

# Copy sources codes
COPY src src

# start build
RUN ./mvnw -U clean package -Dmaven.test.skip=true

# Extract layers
RUN java -Djarmode=layertools -jar target/*.jar extract --destination layers

# =====================
# STEP 2: run container
# =====================
FROM openjdk:11-jdk

# possible JVM options can be given as args
ENV JAVA_OPTS ''
# Provide the class of the main Spring boot application here
ENV JAVA_CLASS 'com.agco.poc.Application'

VOLUME /tmp

# Copy layers to run container
COPY --from=build /app/layers/dependencies /app/
COPY --from=build /app/layers/spring-boot-loader /app/
COPY --from=build /app/layers/snapshot-dependencies /app/
COPY --from=build /app/layers/application /app/

# add the entrypoint script
COPY docker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# entrypoint script will run the unpackaged JAR
ENTRYPOINT ["/docker-entrypoint.sh"]
