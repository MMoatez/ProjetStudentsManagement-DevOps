FROM eclipse-temurin:17-jdk

EXPOSE 8089

COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java","-jar","app.jar"]
