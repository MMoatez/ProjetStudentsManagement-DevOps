# --- Stage 1 : Build avec Maven ---
FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copier le pom.xml seul d'abord (meilleur cache Docker pour les dépendances)
COPY pom.xml ./

# Facultatif : télécharger les dépendances (cache)
RUN mvn dependency:go-offline -B

# Copier le code source
COPY src ./src

# Compiler + packager (skip tests si tu veux)
RUN mvn clean package -DskipTests

# --- Stage 2 : Runtime minimal avec Amazon Corretto ---
FROM amazoncorretto:17-alpine
WORKDIR /app

# Copier le JAR depuis le build
COPY --from=build /app/target/*.jar app.jar

# Exposer le port utilisé (Spring Boot souvent 8080)
EXPOSE 8080

# Démarrer l'application
ENTRYPOINT ["java", "-jar", "app.jar"]
