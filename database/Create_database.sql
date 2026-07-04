CREATE TABLE subject (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    note TEXT,
    color VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE task (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    subject_id INTEGER,

    title VARCHAR(255),
    description TEXT,

    status VARCHAR(50),

    all_day BOOLEAN DEFAULT FALSE,

    start_datetime TIMESTAMPTZ,
    end_datetime TIMESTAMPTZ,

    is_recurring BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_task_subject
        FOREIGN KEY (subject_id)
        REFERENCES subject(id)
        ON DELETE CASCADE
);

CREATE TABLE task_recurrence (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    task_id INTEGER NOT NULL UNIQUE,

    freq VARCHAR(20),
    interval_num INTEGER DEFAULT 1,

    days_of_week INTEGER,

    until_date DATE,

    CONSTRAINT fk_task_recurrence_task
        FOREIGN KEY (task_id)
        REFERENCES task(id)
);


CREATE TABLE task_reminders (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    task_id INTEGER NOT NULL,

    enable BOOLEAN DEFAULT TRUE,

    offset_minutes INTEGER NOT NULL,

    notification_type VARCHAR(50),

    sent BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_task_reminders_task
        FOREIGN KEY (task_id)
        REFERENCES task(id)
);


CREATE TABLE occurrences (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    task_id INTEGER NOT NULL,

    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,

    status VARCHAR(50),

    alarm_sent BOOLEAN DEFAULT FALSE,

    is_exception BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_occurrences_task
        FOREIGN KEY (task_id)
        REFERENCES task(id)
);


CREATE INDEX idx_occurrences_start_datetime
    ON occurrences(start_datetime);

CREATE INDEX idx_occurrences_task_id
    ON occurrences(task_id);

CREATE INDEX idx_task_subject_id
    ON task(subject_id);

CREATE INDEX idx_task_start_datetime
    ON task(start_datetime);

CREATE INDEX idx_task_reminders_task_id
    ON task_reminders(task_id);