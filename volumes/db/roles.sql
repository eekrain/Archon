-- Database roles setup for Supabase
-- This creates the necessary database users with proper authentication
-- Default password is 'supersecretpassword' - change this in production

-- Create or update roles with password authentication
DO $$
BEGIN
    -- Create or update supabase_auth_admin role with password
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_auth_admin') THEN
        CREATE ROLE supabase_auth_admin WITH LOGIN PASSWORD 'supersecretpassword' NOINHERIT CREATEROLE;
    ELSE
        ALTER ROLE supabase_auth_admin WITH LOGIN PASSWORD 'supersecretpassword';
    END IF;
    
    -- Create or update authenticator role with password  
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticator') THEN
        CREATE ROLE authenticator WITH LOGIN PASSWORD 'supersecretpassword' NOINHERIT;
    ELSE
        ALTER ROLE authenticator WITH LOGIN PASSWORD 'supersecretpassword';
    END IF;
    
    -- Create other necessary roles if they don't exist
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'supabase_admin') THEN
        CREATE ROLE supabase_admin NOLOGIN;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN;
    END IF;
END $$;

-- Grant role memberships
GRANT service_role TO supabase_auth_admin;
GRANT authenticated TO supabase_auth_admin;
GRANT anon TO supabase_auth_admin;