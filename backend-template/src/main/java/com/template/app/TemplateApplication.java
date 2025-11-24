package com.template.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Application Entry Point
 * 
 * CUSTOMIZATION:
 * 1. Rename this file to match your application (e.g., AcmeApplication.java)
 * 2. Update the package name (e.g., com.acme.api)
 * 3. Update the class name to match the file name
 * 4. Run: SpringApplication.run(YourApplicationName.class, args);
 * 
 * This template provides:
 * - JWT-based authentication
 * - PostgreSQL database with Flyway migrations
 * - RESTful API with WebFlux (reactive)
 * - Security configuration
 * - Actuator health checks
 * - Ready for deployment to Render
 * 
 * Stack:
 * - Backend: Spring Boot 3.2 (Java 21)
 * - Database: Supabase PostgreSQL
 * - Deployment: Render (Docker)
 * - Frontend: React + Vite (deployed to Vercel)
 */
@SpringBootApplication
public class TemplateApplication {

    public static void main(String[] args) {
        SpringApplication.run(TemplateApplication.class, args);
    }
}

