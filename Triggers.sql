-- Тригер на обмеження: заборона додавання користувачів молодше 6 років
CREATE OR REPLACE FUNCTION check_user_age()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.birth_date > CURRENT_DATE - INTERVAL '6 years' THEN
        RAISE EXCEPTION 'Users must be at least 6 years old to register.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_user_insert
    BEFORE INSERT ON users
    FOR EACH ROW
EXECUTE FUNCTION check_user_age();

insert into users (username, email, password_hash, full_name, birth_date)
values ('john_doe', 'bebra@gmail.com', '123456', 'John Doe', '2020-01-01');

-- Тригер на обмеження: заборона додавання публікацій з некоректними словами
CREATE OR REPLACE FUNCTION check_post_content()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.content ~* '(BadWord|VeryBadWord|BebraWord)' THEN
        RAISE EXCEPTION 'Inappropriate content detected in the post.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_post_check
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
EXECUTE FUNCTION check_post_content();

insert into posts (user_id, content)
values (1, 'This is a post with BadWord in it.');

-- Тригер на обмеження: заборона додавання коментарів з некоректними словами
CREATE OR REPLACE FUNCTION check_comment_content()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.content ~* '(BadWord|VeryBadWord|BebraWord)' THEN
        RAISE EXCEPTION 'Inappropriate content detected in the comment.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_comment_check
    BEFORE INSERT OR UPDATE ON comments
    FOR EACH ROW
EXECUTE FUNCTION check_comment_content();

insert into comments (post_id, user_id, content)
values (1, 1, 'This is a comment with BadWord in it.');

-- Після створення посту: автоматичне створення повідомлення про новий пост для всіх друзів
CREATE OR REPLACE FUNCTION notify_friends_about_post()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notifications (user_id, message, created_at)
    SELECT user_id2, 'Your friend ' || (SELECT username FROM users WHERE user_id = NEW.user_id) || ' made a new post.', CURRENT_TIMESTAMP
    FROM friends
    WHERE user_id1 = NEW.user_id AND status = 'accepted';

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_post_insert
    AFTER INSERT ON posts
    FOR EACH ROW
EXECUTE FUNCTION notify_friends_about_post();

INSERT INTO friends (user_id1, user_id2, status) VALUES (1, 2, 'accepted');
INSERT INTO posts (user_id, content) values (1, 'This is a post with no bad words.');

-- Перед вставкою хештега: приведення до нижнього регістру
CREATE OR REPLACE FUNCTION normalize_hashtag_name()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.name := lower(NEW.name);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_hashtag_insert
    BEFORE INSERT ON hashtags
    FOR EACH ROW
EXECUTE FUNCTION normalize_hashtag_name();

INSERT INTO hashtags (name) VALUES ('#GOODWORD');

-- Після видалення групи: видалення всіх учасників цієї групи
CREATE OR REPLACE FUNCTION cleanup_group_members()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM group_members WHERE group_id = OLD.group_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_group_delete
    AFTER DELETE ON groups
    FOR EACH ROW
EXECUTE FUNCTION cleanup_group_members();

INSERT INTO groups (name, created_by) VALUES ('Group1', 1);
INSERT INTO group_members (group_id, user_id) VALUES (174, 2);
INSERT INTO group_members (group_id, user_id) VALUES (174, 3);
INSERT INTO group_members (group_id, user_id) VALUES (174, 4);
INSERT INTO group_members (group_id, user_id) VALUES (174, 5);
INSERT INTO group_members (group_id, user_id) VALUES (174, 6);

DELETE FROM groups WHERE group_id = 174;

-- Після вставки фото до посту: оновлення часу останнього оновлення посту
CREATE OR REPLACE FUNCTION update_post_on_photo_insert()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts
    SET updated_at = CURRENT_TIMESTAMP
    WHERE post_id = NEW.post_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_photo_insert
    AFTER INSERT ON post_photos
    FOR EACH ROW
EXECUTE FUNCTION update_post_on_photo_insert();

INSERT INTO posts (user_id, content) VALUES (1, 'This is a post with no bad words.');
INSERT INTO post_photos (post_id, photo_url) VALUES (1, 'https://example.com/photo.jpg');

-- Перед оновленням статусу друзів: заборона переходу зі статусу "accepted" у "pending"
CREATE OR REPLACE FUNCTION restrict_friendship_status_change()
    RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'accepted' AND NEW.status = 'pending' THEN
        RAISE EXCEPTION 'Cannot revert accepted friendship to pending.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_friendship_update
    BEFORE UPDATE OF status ON friends
    FOR EACH ROW
EXECUTE FUNCTION restrict_friendship_status_change();

UPDATE friends SET status = 'pending' WHERE friendship_id = 1;

