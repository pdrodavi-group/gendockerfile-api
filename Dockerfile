# build stage
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

# cache dependencies
COPY pom.xml .
RUN mvn -B dependency:resolve

# copy sources and build
COPY src ./src
RUN mvn -B -DskipTests package

# runtime stage
FROM metersphere/alpine-openjdk17-jre
WORKDIR /app

# set default JVM options (can be overridden at runtime)
ENV JAVA_OPTS="-Xms256m -Xmx512m"

# copy built jar (assumes single jar in target/)
ARG JAR_FILE=target/*.jar
COPY --from=build /app/${JAR_FILE} /app/app.jar

EXPOSE 8080

# use sh -c so JAVA_OPTS can be overridden via docker run -e JAVA_OPTS="..."
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar"]
