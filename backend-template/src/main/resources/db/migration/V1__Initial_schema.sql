-- ============================================
-- INITIAL SCHEMA MIGRATION
-- ============================================
-- This is your first Flyway migration
-- Create your schema and core tables here
--
-- BEFORE RUNNING:
-- 1. Update 'public' to your schema name
-- 2. Customize the users table as needed
-- 3. Add other tables your app requires
-- ============================================

-- Set schema (CHANGE THIS to your schema name)
SET search_path TO public;

-- Create schema if it doesn't exist (optional)
-- Uncomment if you want Flyway to create the schema
-- CREATE SCHEMA IF NOT EXISTS your_schema_name;
-- SET search_path TO your_schema_name;

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(50) NOT NULL DEFAULT 'CUSTOMER',
    active BOOLEAN DEFAULT true,
    last_login_timestamp TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(active);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);

-- Comments for documentation
COMMENT ON TABLE users IS 'Application users with authentication credentials';
COMMENT ON COLUMN users.password_hash IS 'BCrypt hashed password - never store plain text';
COMMENT ON COLUMN users.user_type IS 'User role: CUSTOMER, ADMIN, etc.';

-- ============================================
-- EXAMPLE: Additional Tables
-- ============================================
-- Add your application-specific tables here
-- Example: Organizations, Items, Orders, etc.

/*
CREATE TABLE IF NOT EXISTS items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_items_created_by ON items(created_by);
*/

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to automatically update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to users table
CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply to other tables as needed:
-- CREATE TRIGGER items_updated_at
--     BEFORE UPDATE ON items
--     FOR EACH ROW
--     EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SEED DATA (Optional)
-- ============================================
-- Insert initial data here or create a separate V2__Seed_data.sql

-- Example: Insert admin user
-- Password: 'admin123' (hashed with BCrypt)
-- Generate hash using: backend PasswordHashGenerator utility
/*
INSERT INTO users (email, password_hash, first_name, last_name, user_type, active)
VALUES (
    'admin@example.com',
    '$2a$10$REPLACE_WITH_YOUR_HASH',
    'Admin',
    'User',
    'ADMIN',
    true
)
ON CONFLICT (email) DO NOTHING;
*/

-- ============================================
-- NOTES
-- ============================================
-- Migration File Naming Convention:
-- V{version}__{description}.sql
-- Examples:
--   V1__Initial_schema.sql
--   V2__Add_items_table.sql
--   V3__Add_user_roles.sql
--
-- Flyway Best Practices:
-- - Never modify existing migrations after they're deployed
-- - Use sequential version numbers
-- - Keep migrations small and focused
-- - Test migrations on a copy of production data
-- - Use reversible changes when possible
--
-- To generate password hash for testing:
-- Run: ./mvnw exec:java -Dexec.mainClass="com.template.app.util.PasswordHashGenerator"
-- ============================================

