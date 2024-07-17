FROM openjdk:17.0.2-jdk
EXPOSE 8080
RUN mkdir /opt/app
COPY build/libs/bootcamp-docker-java-mysql-project-1.0-SNAPSHOT.jar /opt/app
WORKDIR /opt/app
CMD ["java", "-jar", "bootcamp-docker-java-mysql-project-1.0-SNAPSHOT.jar"]