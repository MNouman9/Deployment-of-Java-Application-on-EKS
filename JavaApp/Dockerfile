# === Stage 1: Build with Maven ===
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src

# RUN mvn package
RUN mvn clean package -DskipTests

# === Stage 2: Runtime ===
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar

CMD ["java", "-jar", "app.jar"]
