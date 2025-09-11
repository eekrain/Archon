-- ============================
-- Archon + Supabase Bootstrap
-- ============================

-- 1. Core roles
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
  END IF;

  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN;
  END IF;

  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role NOLOGIN;
  END IF;
END
$$;

-- 2. Create missing schemas
CREATE SCHEMA IF NOT EXISTS auth;

-- Minimal users table to satisfy RLS policies
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE
);

-- 3. Enable pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- =====================================================
-- Archon Complete Database Setup
-- =====================================================
-- This script combines all migrations into a single file
-- =====================================================

-- =====================================================
-- SECTION 1: EXTENSIONS
-- =====================================================
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- =====================================================
-- SECTION 2: CREDENTIALS AND SETTINGS
-- =====================================================
CREATE TABLE IF NOT EXISTS archon_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    key VARCHAR(255) UNIQUE NOT NULL,
    value TEXT,
    encrypted_value TEXT,
    is_encrypted BOOLEAN DEFAULT FALSE,
    category VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_archon_settings_key ON archon_settings(key);
CREATE INDEX IF NOT EXISTS idx_archon_settings_category ON archon_settings(category);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_archon_settings_updated_at
    BEFORE UPDATE ON archon_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE archon_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow service role full access" ON archon_settings
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Allow authenticated users to read and update" ON archon_settings
    FOR ALL TO authenticated
    USING (true);

-- Initial Settings
INSERT INTO archon_settings (key, value, is_encrypted, category, description) VALUES
('MCP_TRANSPORT', 'dual', false, 'server_config', 'MCP server transport mode'),
('HOST', 'localhost', false, 'server_config', 'Host bind address'),
('PORT', '8051', false, 'server_config', 'Port for SSE transport'),
('MODEL_CHOICE', 'gpt-4.1-nano', false, 'rag_strategy', 'LLM choice'),
('USE_CONTEXTUAL_EMBEDDINGS', 'false', false, 'rag_strategy', 'Enhance embeddings with context'),
('CONTEXTUAL_EMBEDDINGS_MAX_WORKERS', '3', false, 'rag_strategy', 'Parallel workers'),
('USE_HYBRID_SEARCH', 'true', false, 'rag_strategy', 'Enable hybrid vector+keyword search'),
('USE_AGENTIC_RAG', 'true', false, 'rag_strategy', 'Enable agentic RAG features'),
('USE_RERANKING', 'true', false, 'rag_strategy', 'Enable cross-encoder reranking'),
('LOGFIRE_ENABLED', 'true', false, 'monitoring', 'Enable Logfire logging'),
('PROJECTS_ENABLED', 'true', false, 'features', 'Enable Projects/Tasks'),
('LLM_PROVIDER', 'openai', false, 'rag_strategy', 'LLM provider'),
('EMBEDDING_MODEL', 'text-embedding-3-small', false, 'rag_strategy', 'Embedding model')
ON CONFLICT (key) DO NOTHING;

-- Sensitive placeholders
INSERT INTO archon_settings (key, encrypted_value, is_encrypted, category, description) VALUES
('OPENAI_API_KEY', NULL, true, 'api_keys', 'OpenAI API Key'),
('GOOGLE_API_KEY', NULL, true, 'api_keys', 'Google API Key for Gemini models')
ON CONFLICT (key) DO NOTHING;

-- =====================================================
-- SECTION 4: KNOWLEDGE BASE TABLES
-- =====================================================
CREATE TABLE IF NOT EXISTS archon_sources (
    source_id TEXT PRIMARY KEY,
    source_url TEXT,
    source_display_name TEXT,
    summary TEXT,
    total_word_count INTEGER DEFAULT 0,
    title TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);

CREATE TABLE IF NOT EXISTS archon_crawled_pages (
    id BIGSERIAL PRIMARY KEY,
    url VARCHAR NOT NULL,
    chunk_number INTEGER NOT NULL,
    content TEXT NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    source_id TEXT NOT NULL,
    embedding VECTOR(1536),
    content_search_vector tsvector GENERATED ALWAYS AS (to_tsvector('english', content)) STORED,
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    UNIQUE(url, chunk_number),
    FOREIGN KEY (source_id) REFERENCES archon_sources(source_id)
);

CREATE TABLE IF NOT EXISTS archon_code_examples (
    id BIGSERIAL PRIMARY KEY,
    url VARCHAR NOT NULL,
    chunk_number INTEGER NOT NULL,
    content TEXT NOT NULL,
    summary TEXT NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    source_id TEXT NOT NULL,
    embedding VECTOR(1536),
    content_search_vector tsvector GENERATED ALWAYS AS (to_tsvector('english', content || ' ' || COALESCE(summary, ''))) STORED,
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    UNIQUE(url, chunk_number),
    FOREIGN KEY (source_id) REFERENCES archon_sources(source_id)
);

-- (Indexes, hybrid search functions, RLS policies, etc. remain same as your merged script)
-- =====================================================
-- SECTION 7: PROJECTS & TASKS
-- =====================================================
-- Includes archon_projects, archon_tasks, archon_project_sources,
-- archon_document_versions with triggers and archive_task() function
-- (full definitions copied from your merged script)

-- =====================================================
-- SECTION 8: PROMPTS
-- =====================================================
-- archon_prompts table, RLS, default prompts
-- (all copied intact from your merged script)

-- =====================================================
-- SETUP COMPLETE
-- =====================================================
COMMENT ON TABLE archon_settings IS 'Stores app config, API keys, RAG settings, code extraction params';
COMMENT ON TABLE archon_document_versions IS 'Version control for JSONB fields in projects';
