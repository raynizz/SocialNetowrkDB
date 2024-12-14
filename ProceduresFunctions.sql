-- Отримання всіх коментарів до посту
CREATE OR REPLACE FUNCTION get_post_comments(id_post INT)
    RETURNS TABLE
            (
                post_id    INT,
                username   VARCHAR(50),
                content    TEXT,
                created_at TIMESTAMP
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY SELECT posts.post_id,
                        users.username,
                        comments.content,
                        comments.created_at
                 FROM comments
                          JOIN posts ON comments.post_id = posts.post_id
                          JOIN users ON comments.user_id = users.user_id
                 WHERE posts.post_id = id_post;
END;
$$;

SELECT *
FROM get_post_comments(749);

-- Отримання кількості лайків до посту
CREATE OR REPLACE FUNCTION get_post_likes(id_post INT)
    RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
    likes_count INT;
BEGIN
    SELECT COUNT(*)
    INTO likes_count
    FROM likes
    WHERE likes.post_id = id_post;
    RETURN likes_count;
END;
$$;

SELECT get_post_likes(1000);

-- Отримати кількість коментарів до посту
CREATE OR REPLACE FUNCTION get_post_comments_count(id_post INT)
    RETURNS INT
    LANGUAGE plpgsql
AS
$$
DECLARE
    comments_count INT;
BEGIN
    SELECT COUNT(*)
    INTO comments_count
    FROM comments
    WHERE comments.post_id = id_post;
    RETURN comments_count;
END;
$$;

SELECT get_post_comments_count(749);

-- Знайти профіль користувача за ніком
CREATE OR REPLACE FUNCTION find_user_profile_by_username(username_query VARCHAR(50))
    RETURNS TABLE
            (
                user_id    INT,
                username   VARCHAR(50),
                email      VARCHAR(50),
                full_name  VARCHAR(100),
                avatar     VARCHAR(255),
                bio        TEXT,
                created_at TIMESTAMP
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY SELECT users.user_id,
                        users.username,
                        users.email,
                        users.full_name,
                        profiles.profile_picture_url,
                        profiles.bio,
                        users.created_at
                 FROM users
                          JOIN profiles ON users.user_id = profiles.user_id
                 WHERE users.username LIKE '%' || username_query || '%';
END;
$$;

SELECT *
FROM find_user_profile_by_username('cbo');

-- Оновлення пароля користувача
CREATE OR REPLACE PROCEDURE update_user_password(id_user INT, new_password VARCHAR(255), repited_password VARCHAR(255))
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF new_password = repited_password THEN
        UPDATE users
        SET password_hash = new_password
        WHERE users.user_id = id_user;
    ELSE
        RAISE EXCEPTION 'Passwords do not match';
    END IF;
END;
$$;

CALL update_user_password(1, 'new_password', 'newpassword');
CALL update_user_password(1, 'new_password', 'new_password');
SELECT *
FROM users
WHERE user_id = 1;

-- Видалення коментаря
CREATE OR REPLACE PROCEDURE delete_comment(id_comment INT)
    LANGUAGE plpgsql
AS
$$
BEGIN
    DELETE
    FROM comments
    WHERE comments.comment_id = id_comment;
END;
$$;

INSERT INTO comments (post_id, user_id, content)
VALUES (3, 1, 'Test comment');
SELECT *
FROM comments
WHERE post_id = 3;
CALL delete_comment(1003);

-- Отримання списку друзів користувача
CREATE OR REPLACE FUNCTION get_user_friends(id_user INT)
    RETURNS TABLE
            (
                friend_id  INT,
                username   VARCHAR(50),
                email      VARCHAR(100),
                full_name  VARCHAR(100),
                avatar     VARCHAR(255),
                bio        TEXT,
                created_at TIMESTAMP
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY SELECT users.user_id,
                        users.username,
                        users.email,
                        users.full_name,
                        profiles.profile_picture_url,
                        profiles.bio,
                        users.created_at
                 FROM users
                          JOIN profiles ON users.user_id = profiles.user_id
                          JOIN friends ON users.user_id = friends.user_id2 OR users.user_id = friends.user_id1
                 WHERE friends.user_id1 = id_user
                    OR friends.user_id2 = id_user AND friends.status = 'accepted' AND users.user_id != id_user;
END;
$$;

SELECT *
FROM get_user_friends(1);

-- Додавання друзів
CREATE OR REPLACE PROCEDURE add_friend(id_user1 INT, id_user2 INT)
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO friends (user_id1, user_id2, status)
    VALUES (id_user1, id_user2, 'pending');
END;
$$;

CALL add_friend(1, 5);

SELECT *
FROM friends
WHERE user_id1 = 1;

-- Прийняти всі запити в друзі
CREATE OR REPLACE PROCEDURE accept_all_friend_requests(id_user INT)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE friends
    SET status = 'accepted'
    WHERE user_id2 = id_user
      AND status = 'pending';
END;
$$;

CALL accept_all_friend_requests(5);

SELECT *
FROM get_user_friends(5);

-- Отримати групу з учасниками
CREATE OR REPLACE FUNCTION get_group_members(id_group INT)
    RETURNS TABLE
            (
                group_name          VARCHAR(100),
                role                VARCHAR(20),
                username            VARCHAR(50),
                email               VARCHAR(100),
                profile_picture_url VARCHAR(255),
                full_name           VARCHAR(100),
                bio                 TEXT

            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY SELECT groups.name
                            AS group_name,
                        group_members.role,
                        users.username,
                        users.email,
                        profiles.profile_picture_url,
                        users.full_name,
                        profiles.bio
                 FROM group_members
                          JOIN users ON group_members.user_id = users.user_id
                          JOIN profiles ON users.user_id = profiles.user_id
                          JOIN groups ON group_members.group_id = groups.group_id
                 WHERE group_members.group_id = id_group;
END;
$$;

drop function get_group_members;

SELECT *
FROM get_group_members(33);

-- Створити новий хештег для посту
CREATE OR REPLACE PROCEDURE add_hashtag_to_post(id_post INT, hashtag_name VARCHAR(50))
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO hashtags (name)
    VALUES (hashtag_name);
    INSERT INTO post_hashtags (post_id, hashtag_id)
    VALUES (id_post, (SELECT hashtag_id
                      FROM hashtags
                      WHERE hashtags.name = lower(hashtag_name)));
END;
$$;

SELECT posts.post_id, posts.content, hashtags.name
FROM posts
         JOIN post_hashtags ON posts.post_id = post_hashtags.post_id
         JOIN hashtags ON post_hashtags.hashtag_id = hashtags.hashtag_id
WHERE posts.post_id = 5;

CALL add_hashtag_to_post(5, '#FAWGVAWEF');