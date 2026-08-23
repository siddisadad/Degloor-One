FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY target/degloor-one-backend-0.1.0.jar app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod
ENTRYPOINT ["java","-jar","/app/app.jar"]
