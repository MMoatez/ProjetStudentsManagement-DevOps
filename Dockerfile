FROM openjdk:17-jdk

WORKDIR /app

EXPOSE 8089

COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java","-jar","app.jar"]
