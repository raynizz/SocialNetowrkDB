CREATE TABLE users
(
    user_id       SERIAL PRIMARY KEY,
    username      VARCHAR(50) UNIQUE  NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255)        NOT NULL,
    full_name     VARCHAR(100),
    birth_date    DATE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_birth_date CHECK (birth_date < CURRENT_DATE)
);

CREATE TABLE profiles
(
    profile_id      SERIAL PRIMARY KEY,
    user_id         INTEGER UNIQUE NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    bio             TEXT,
    profile_picture_url VARCHAR(255) DEFAULT 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKaiKiPcLJj7ufrj6M2KaPwyCT4lDSFA5oog&s',
    location        VARCHAR(100),
    visibility      VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'private'))
);

CREATE TABLE posts
(
    post_id    SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    content    TEXT    NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
    CONSTRAINT chk_content_length CHECK (LENGTH(content) <= 500)
);

CREATE TABLE post_photos
(
    photo_id   SERIAL PRIMARY KEY,
    post_id    INTEGER NOT NULL REFERENCES posts (post_id) ON DELETE CASCADE,
    photo_url  VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_photo_url CHECK (LENGTH(photo_url) > 0)
);

CREATE TABLE comments
(
    comment_id SERIAL PRIMARY KEY,
    post_id    INTEGER NOT NULL REFERENCES posts (post_id) ON DELETE CASCADE,
    user_id    INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    content    TEXT    NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE likes
(
    like_id    SERIAL PRIMARY KEY,
    post_id    INTEGER NOT NULL REFERENCES posts (post_id) ON DELETE CASCADE,
    user_id    INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (post_id, user_id)
);

CREATE TABLE friends
(
    friendship_id SERIAL PRIMARY KEY,
    user_id1      INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    user_id2      INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    status        VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    created_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id1, user_id2),
    CONSTRAINT chk_friends_self_relationship CHECK (user_id1 <> user_id2)

);

CREATE TABLE messages
(
    message_id  SERIAL PRIMARY KEY,
    sender_id   INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    receiver_id INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    content     TEXT    NOT NULL,
    sent_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read     BOOLEAN   DEFAULT FALSE,
    CONSTRAINT chk_message_length CHECK (LENGTH(content) > 0)
);

CREATE TABLE groups
(
    group_id    SERIAL PRIMARY KEY,
    name        VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_by  INTEGER             NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_members
(
    group_member_id SERIAL PRIMARY KEY,
    group_id        INTEGER NOT NULL REFERENCES groups (group_id) ON DELETE CASCADE,
    user_id         INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    role            VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'member')),
    joined_at       TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (group_id, user_id)
);

CREATE TABLE notifications
(
    notification_id SERIAL PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users (user_id) ON DELETE CASCADE,
    message         TEXT    NOT NULL,
    is_read         BOOLEAN   DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE hashtags
(
    hashtag_id SERIAL PRIMARY KEY,
    name       VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE post_hashtags
(
    post_id    INTEGER NOT NULL REFERENCES posts (post_id) ON DELETE CASCADE,
    hashtag_id INTEGER NOT NULL REFERENCES hashtags (hashtag_id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, hashtag_id)
);

ALTER TABLE users ADD CONSTRAINT check_email CHECK ( email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

ALTER TABLE posts ADD CONSTRAINT chk_updated_at CHECK (updated_at >= created_at);

ALTER TABLE hashtags ADD CONSTRAINT chk_hashtag_name CHECK (name LIKE '#%');