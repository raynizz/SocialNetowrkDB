-- Створення ролі Адмін ----------------------------------------------
CREATE ROLE admin;

-- Роль admin: повний доступ до всіх таблиць
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

CREATE USER admin_user WITH PASSWORD 'admin1';
GRANT admin TO admin_user;

-- Створення ролі Модератор ----------------------------------------------
CREATE ROLE moderator;

-- Роль moderator: читання даних, управління контентом
GRANT SELECT ON ALL TABLES IN SCHEMA public TO moderator;
GRANT DELETE ON posts, comments, hashtags, post_photos TO moderator;

CREATE USER moderator_user WITH PASSWORD 'moderator1';
GRANT moderator TO moderator_user;

-- Створення ролі Творець контенту----------------------------------------------
CREATE ROLE content_creator;

-- Роль content_creator: створення та редагування власного контенту
GRANT SELECT, INSERT, UPDATE, DELETE ON posts, post_photos TO content_creator;
GRANT UPDATE, INSERT ON users, profiles TO content_creator;

-- Таблиця profiles: дозволити оновлення тільки власного профілю
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY content_creator_update_own_profile
    ON profiles
    FOR UPDATE
    USING (user_id = current_setting('social_network.current_user_id')::INTEGER);

GRANT UPDATE ON TABLE profiles TO content_creator;

-- Таблиця posts: дозволити редагувати лише власні пости
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY content_creator_update_own_post
    ON posts
    FOR UPDATE
    USING (user_id = current_setting('social_network.current_user_id')::INTEGER);

GRANT UPDATE, DELETE ON TABLE posts TO content_creator;

SET social_network.current_user_id = 5;

CREATE USER content_creator_user WITH PASSWORD 'creator5';
GRANT content_creator TO content_creator_user;


-- Створення ролі Користувач ----------------------------------------------
CREATE ROLE regular_user;

-- Роль regular_user: створення контенту та редагування власного профілю
GRANT SELECT, INSERT, UPDATE, DELETE ON posts, comments, likes TO regular_user;
GRANT UPDATE ON users, profiles TO regular_user;

-- Таблиця profiles: дозволити оновлення тільки власного профілю
CREATE POLICY regular_user_update_own_profile
    ON profiles
    FOR UPDATE
    USING (user_id = current_setting('social_network.current_user_id')::INTEGER);

GRANT UPDATE ON TABLE profiles TO regular_user;

-- Таблиця posts: дозволити редагувати лише власні пости

CREATE POLICY regular_user_update_own_post
    ON posts
    FOR UPDATE
    USING (user_id = current_setting('social_network.current_user_id')::INTEGER);

GRANT UPDATE, DELETE ON TABLE posts TO regular_user;

-- Таблиця comments: дозволити редагувати лише власні коментарі
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY regular_user_update_own_comment
    ON comments
    FOR UPDATE
    USING (user_id = current_setting('social_network.current_user_id')::INTEGER);

GRANT UPDATE, DELETE ON TABLE comments TO regular_user;

-- Таблиця likes: дозволити додавати та видаляти власні лайки
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY regular_user_manage_own_likes
    ON likes
    FOR ALL
    USING (user_id = current_setting('social_network.current_user_id')::INTEGER);

GRANT INSERT, DELETE ON TABLE likes TO regular_user;

SET social_network.current_user_id = 20;

CREATE USER just_user WITH PASSWORD 'user20';
GRANT regular_user TO just_user;

