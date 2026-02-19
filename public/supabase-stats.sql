-- Co-Writer Writing Stats Tracking
-- Voer dit uit in Supabase SQL Editor

-- Maak writing_stats tabel
CREATE TABLE IF NOT EXISTS writing_stats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL,
    words_written INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- Maak user_settings tabel voor daily goal
CREATE TABLE IF NOT EXISTS user_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    daily_word_goal INT DEFAULT 500,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    total_words_written INT DEFAULT 0,
    last_write_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS writing_stats_user_date_idx ON writing_stats(user_id, date DESC);
CREATE INDEX IF NOT EXISTS user_settings_user_id_idx ON user_settings(user_id);

-- RLS Policies voor writing_stats
ALTER TABLE writing_stats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own stats" ON writing_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats" ON writing_stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats" ON writing_stats
    FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies voor user_settings
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own settings" ON user_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON user_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON user_settings
    FOR UPDATE USING (auth.uid() = user_id);
