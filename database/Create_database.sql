-- =========================
-- ENUMS
-- =========================

CREATE TYPE task_status AS ENUM (
    'pending',
    'in_progress',
    'completed',
    'cancelled'
);

CREATE TYPE recurrence_frequency AS ENUM (
    'daily',
    'weekly',
    'monthly',
    'yearly'
);

-- =========================
-- SUBJECT
-- =========================

CREATE TABLE subject (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    note TEXT,
    color VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================
-- TASK
-- =========================

CREATE TABLE task (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subject_id INTEGER,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status task_status NOT NULL DEFAULT 'pending',
    all_day BOOLEAN NOT NULL DEFAULT FALSE,
    start_datetime TIMESTAMPTZ,
    end_datetime TIMESTAMPTZ,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_task_subject FOREIGN KEY (subject_id) REFERENCES subject (id) ON DELETE CASCADE
);

-- =========================
-- RECURRENCE
-- =========================


CREATE TABLE task_recurrence (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    task_id INTEGER NOT NULL UNIQUE,

    freq recurrence_frequency NOT NULL,

    interval_num INTEGER NOT NULL DEFAULT 1
        CHECK (interval_num > 0),

/*
Bitmask

Sunday    = 1
Monday    = 2
Tuesday   = 4
Wednesday = 8
Thursday  = 16
Friday    = 32
Saturday  = 64
*/
days_of_week INTEGER DEFAULT 0,

    until_date DATE,

    CONSTRAINT fk_task_recurrence_task
        FOREIGN KEY (task_id)
        REFERENCES task(id)
        ON DELETE CASCADE
);

-- =========================
-- REMINDERS
-- =========================

CREATE TABLE task_reminders (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id INTEGER NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    offset_minutes INTEGER NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    sent BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_task_reminders_task FOREIGN KEY (task_id) REFERENCES task (id) ON DELETE CASCADE
);

-- =========================
-- OCCURRENCES
-- =========================

CREATE TABLE occurrences (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id INTEGER NOT NULL,
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    status task_status NOT NULL DEFAULT 'pending',
    alarm_sent BOOLEAN NOT NULL DEFAULT FALSE,
    is_exception BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_occurrences_task FOREIGN KEY (task_id) REFERENCES task (id) ON DELETE CASCADE
);

-- =========================
-- INDEXES
-- =========================

CREATE INDEX idx_occurrences_start_datetime ON occurrences (start_datetime);

CREATE INDEX idx_occurrences_task_id ON occurrences (task_id);

CREATE INDEX idx_task_subject_id ON task (subject_id);

CREATE INDEX idx_task_start_datetime ON task (start_datetime);

CREATE INDEX idx_task_reminders_task_id ON task_reminders (task_id);

CREATE INDEX idx_task_status ON task (status);