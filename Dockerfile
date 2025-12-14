FROM openjdk:17
EXPOSE 8089
ADD target/student-management-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]
