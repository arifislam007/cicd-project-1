# Use an official Maven runtime as a parent image
FROM maven:3.8.2-openjdk-11-slim AS build

# Set the working directory in the container
WORKDIR /app

# Copy the pom.xml file
COPY pom.xml .

# Download all dependencies (Maven will download them)
RUN mvn dependency:go-offline -B

# Copy the rest of the application code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Use an official OpenJDK 11 runtime as a parent image
FROM openjdk:11-jre-slim

# Set the working directory in the container
WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port 8080 to the outside world
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
