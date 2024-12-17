-- Отримати всі публічні пости з фото, які мають лайки та коментарі
SELECT users.username,
       post_photos.photo_url,
       posts.content,
       get_post_likes(posts.post_id)          AS likes_count,
       get_post_comments_count(posts.post_id) AS comments_count,
       posts.created_at
FROM users
         JOIN posts ON users.user_id = posts.user_id
         JOIN post_photos ON posts.post_id = post_photos.post_id
         JOIN profiles ON users.user_id = profiles.user_id
WHERE profiles.visibility = 'public';

-- Отримати всі групи, які мають більше 9 учасників
SELECT groups.name,
       groups.description,
       groups.created_at,
       COUNT(users.user_id) AS members_count
FROM groups
         JOIN group_members ON groups.group_id = group_members.group_id
         JOIN users ON group_members.user_id = users.user_id
GROUP BY groups.name, groups.description, groups.created_at
HAVING (COUNT(users.user_id) > 9)
ORDER BY members_count DESC;

-- Отримати всіх користувачів, які створили групи за останній рік
SELECT users.username     AS creator_name,
       groups.name        AS group_name,
       groups.description as group_description,
       groups.created_at
FROM users
         JOIN groups ON users.user_id = groups.created_by
WHERE NOW() - groups.created_at < INTERVAL '1 year';

-- Отримати всіх користувачів, які мають більше 4 друзів
SELECT users.username,
       users.full_name,
       profiles.bio,
       COUNT(friends.friendship_id) AS friends_count
FROM users
         JOIN friends ON users.user_id = friends.user_id1
         JOIN profiles ON users.user_id = profiles.user_id
GROUP BY users.username, users.full_name, profiles.bio
HAVING COUNT(friends.friendship_id) > 4
ORDER BY friends_count DESC;

-- Отримати всі коментарі до посту з інформацією про автора коментаря та посту
SELECT comments.comment_id,
       comments.content,
       comment_author.username AS comment_author,
       post_author.username    AS post_author
FROM comments
         JOIN users AS comment_author ON comments.user_id = comment_author.user_id
         JOIN posts ON comments.post_id = posts.post_id
         JOIN users AS post_author ON posts.user_id = post_author.user_id
WHERE comments.post_id = (SELECT post_id FROM posts ORDER BY created_at DESC LIMIT 1);

-- Отримати користувача, у якого найбільше постів
SELECT users.user_id,
       users.username,
       profiles.profile_picture_url,
       profiles.bio,
       COUNT(posts.post_id) AS post_count
FROM users
         JOIN profiles ON users.user_id = profiles.user_id
         JOIN posts ON users.user_id = posts.user_id
GROUP BY users.username, profiles.profile_picture_url, profiles.bio, users.user_id
ORDER BY post_count DESC
LIMIT 1;

-- Отримати всі пости, які мають більше 4 хештегів
SELECT posts.post_id,
       posts.content,
       post_photos.photo_url,
       STRING_AGG(hashtags.name, ', ') AS hashtags
FROM posts
         JOIN post_hashtags ON posts.post_id = post_hashtags.post_id
         JOIN hashtags ON post_hashtags.hashtag_id = hashtags.hashtag_id
         JOIN post_photos ON posts.post_id = post_photos.post_id
GROUP BY posts.post_id, posts.content, post_photos.photo_url
HAVING COUNT(post_hashtags.hashtag_id) > 4;

-- Отримати всі групи та учасників, створені за останній рік
SELECT groups.name                      AS group_name,
       groups.description,
       groups.created_at,
       STRING_AGG(users.username, ', ') AS member_names
FROM groups
         JOIN group_members ON groups.group_id = group_members.group_id
         JOIN users ON group_members.user_id = users.user_id
WHERE groups.created_at >= NOW() - INTERVAL '3 months'
GROUP BY groups.name, groups.description, groups.created_at
ORDER BY groups.created_at DESC;

-- Вивести останнє сповіщення для користувача
SELECT users.username,
       notifications.notification_id,
       notifications.message,
       notifications.created_at
FROM notifications
         JOIN users ON notifications.user_id = users.user_id
WHERE notifications.user_id = users.user_id
ORDER BY notifications.created_at DESC
LIMIT 1;

-- Отримати всіх користувачів, які мають більше 4 непрочитаних повідомлень
SELECT users.username,
       users.full_name,
       COUNT(messages.message_id) AS unread_messages_count
FROM users
         JOIN messages ON users.user_id = messages.receiver_id
WHERE messages.is_read = FALSE
GROUP BY users.username, users.full_name
HAVING COUNT(messages.message_id) > 4;

-- Отримати користувачів і їх профілі, які повністю заповнені
SELECT users.username,
       users.email,
       users.full_name,
       users.birth_date,
       profiles.bio,
       profiles.profile_picture_url,
       profiles.location,
       profiles.visibility
FROM users
         JOIN profiles ON users.user_id = profiles.user_id
WHERE users.full_name IS NOT NULL
  AND users.birth_date IS NOT NULL
  AND profiles.bio IS NOT NULL
  AND profiles.location IS NOT NULL
ORDER BY users.username;

-- Отримати список лайків, які зробив користувач за останній тиждень
SELECT likes.like_id,
       likes.post_id,
       likes.created_at,
       posts.content  AS post_content,
       users.username AS liked_by
FROM likes
         JOIN posts ON likes.post_id = posts.post_id
         JOIN users ON likes.user_id = users.user_id
WHERE likes.created_at >= NOW() - INTERVAL '1 week'
ORDER BY likes.created_at DESC;

-- Отримати всіх користувачів з України
SELECT profile_picture_url,
       (SELECT username FROM users WHERE users.user_id = profiles.user_id) AS username,
       (SELECT full_name FROM users WHERE users.user_id = profiles.user_id) AS full_name,
       bio,
       location
FROM profiles
WHERE location LIKE '%Ukraine%'
  AND user_id IN (SELECT user_id FROM users);

-- Отримати всіх учасників груп, у яких державна пошта
SELECT users.username,
       users.email,
       groups.name AS group_name
FROM users
         JOIN group_members ON users.user_id = group_members.user_id
         JOIN groups ON group_members.group_id = groups.group_id
WHERE users.email LIKE '%@%.gov%'
ORDER BY groups.name, users.username;

-- Отримати всі пости, які мають хештеги, що містять слово "aw"
SELECT posts.post_id,
       post_photos.photo_url,
       posts.content,
       STRING_AGG(hashtags.name, ', ') AS hashtags
FROM posts
         JOIN post_photos ON posts.post_id = post_photos.post_id
         JOIN post_hashtags ON posts.post_id = post_hashtags.post_id
         JOIN hashtags ON post_hashtags.hashtag_id = hashtags.hashtag_id
WHERE hashtags.name LIKE '%aw%'
GROUP BY posts.post_id, posts.content, post_photos.photo_url
ORDER BY posts.post_id;

-- Отримати користувачів, які додали більше 2 фото до постів
SELECT users.username,
       COUNT(post_photos.photo_id) AS photo_count
FROM users
         JOIN posts ON users.user_id = posts.user_id
         JOIN post_photos ON posts.post_id = post_photos.post_id
GROUP BY users.username
HAVING COUNT(post_photos.photo_id) > 2;

-- Отримати пости, які не мають коментарів або лайків взагалі
SELECT posts.post_id,
       post_photos.photo_url,
       posts.content
FROM posts
         JOIN post_photos ON posts.post_id = post_photos.post_id
         LEFT JOIN comments ON posts.post_id = comments.post_id
         LEFT JOIN likes ON posts.post_id = likes.post_id
WHERE comments.comment_id IS NULL
  AND likes.like_id IS NULL;

-- Отримати найпопулярніший хештег за кількістю використань
SELECT name,
       (SELECT COUNT(post_id)
        FROM post_hashtags
        WHERE post_hashtags.hashtag_id = hashtags.hashtag_id) AS usage_count
FROM hashtags
ORDER BY usage_count DESC
LIMIT 1;

-- Отримати користувачів, які отримали сумарно більше 4 лайків на свої пости
SELECT username,
       (SELECT SUM(get_post_likes(post_id))
        FROM posts
        WHERE posts.user_id = users.user_id) AS total_likes
FROM users
WHERE (SELECT SUM(get_post_likes(post_id))
       FROM posts
       WHERE posts.user_id = users.user_id) > 4
ORDER BY total_likes DESC;

-- Отримати кількість непрочитаних повідомлень для кожного користувача
SELECT
    u.username,
    (
        SELECT COUNT(m.message_id)
        FROM messages m
        WHERE m.receiver_id = u.user_id AND m.is_read = FALSE
    ) AS unread_messages_count
FROM
    users u
ORDER BY unread_messages_count DESC;