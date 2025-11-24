-- ============================================
-- SUPABASE DATABASE SETUP TEMPLATE
-- ============================================
-- This script sets up your database schema, tables, and initial data
-- 
-- BEFORE RUNNING:
-- 1. Replace 'your_app_schema' with your schema name (e.g., 'my_app', 'acme_corp')
-- 2. Update the admin user email and generate a password hash
-- 3. Customize tables as needed for your application
--
-- RUN THIS IN: Supabase SQL Editor
-- ============================================

-- Create custom schema (keeps your tables separate from Supabase internals)
CREATE SCHEMA IF NOT EXISTS your_app_schema;
SET search_path TO your_app_schema;

-- ============================================
-- CORE TABLES
-- ============================================

-- Users table with authentication
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    user_type VARCHAR(50) NOT NULL DEFAULT 'USER',
    active BOOLEAN DEFAULT true,
    last_login_timestamp TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(active);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);

-- Add comment for documentation
COMMENT ON TABLE users IS 'Application users with authentication credentials';

-- ============================================
-- EXAMPLE: Additional tables for your app
-- ============================================
-- Uncomment and customize these example tables:

/*
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_organizations_active ON organizations(active);

CREATE TABLE IF NOT EXISTS items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_items_org ON items(organization_id);
CREATE INDEX IF NOT EXISTS idx_items_status ON items(status);
*/

-- ============================================
-- INITIAL DATA
-- ============================================

-- Insert initial admin user
-- PASSWORD: Generate using backend PasswordHashGenerator utility
-- Example: ./mvnw exec:java -Dexec.mainClass="com.template.app.util.PasswordHashGenerator"
INSERT INTO users (id, email, password_hash, first_name, last_name, user_type, active, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'admin@example.com',  -- CHANGE THIS
    '$2a$10$REPLACE_WITH_YOUR_GENERATED_HASH',  -- CHANGE THIS
    'Admin',
    'User',
    'ADMIN',
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (email) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    user_type = EXCLUDED.user_type,
    active = EXCLUDED.active,
    updated_at = CURRENT_TIMESTAMP;

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
DROP TRIGGER IF EXISTS users_updated_at ON users;
CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply to other tables (uncomment as needed):
-- DROP TRIGGER IF EXISTS organizations_updated_at ON organizations;
-- CREATE TRIGGER organizations_updated_at
--     BEFORE UPDATE ON organizations
--     FOR EACH ROW
--     EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- OPTIONAL: ROW LEVEL SECURITY (RLS)
-- ============================================
-- Uncomment to enable Row Level Security for additional protection

/*
-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own data
CREATE POLICY users_select_own
    ON users
    FOR SELECT
    USING (id = auth.uid());

-- Policy: Users can update their own data
CREATE POLICY users_update_own
    ON users
    FOR UPDATE
    USING (id = auth.uid());

-- Policy: Admins can see all users
CREATE POLICY users_admin_all
    ON users
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND user_type = 'ADMIN'
        )
    );
*/

-- ============================================
-- VERIFICATION
-- ============================================

-- Verify admin user was created
SELECT 
    email, 
    first_name, 
    last_name, 
    user_type, 
    active,
    created_at
FROM users 
WHERE email = 'admin@example.com';

-- Expected result: 1 row showing the admin user

-- ============================================
-- NEXT STEPS
-- ============================================
-- 1. ✅ Run this script in Supabase SQL Editor
-- 2. ✅ Verify admin user exists (query above)
-- 3. ✅ Note your schema name for backend configuration
-- 4. ✅ Update application.yml with schema name
-- 5. ✅ Continue with backend deployment
-- ============================================

