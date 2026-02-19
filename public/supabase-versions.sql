-- Co-Writer Version History / Snapshots
-- Voer dit uit in Supabase SQL Editor

-- Maak story_versions tabel voor version history
CREATE TABLE IF NOT EXISTS story_versions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    story_id UUID REFERENCES stories(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    draft_text TEXT DEFAULT '',
    final_text TEXT DEFAULT '',
    version_number INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS story_versions_story_id_idx ON story_versions(story_id, version_number DESC);
CREATE INDEX IF NOT EXISTS story_versions_user_id_idx ON story_versions(user_id);

-- RLS Policies
ALTER TABLE story_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own versions" ON story_versions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own versions" ON story_versions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own versions" ON story_versions
    FOR DELETE USING (auth.uid() = user_id);

-- Add version counter to stories table
ALTER TABLE stories ADD COLUMN IF NOT EXISTS current_version INT DEFAULT 0;
