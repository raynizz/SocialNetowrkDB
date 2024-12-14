-- Представлення всіх постів з таблиці posts
CREATE VIEW posts_information AS
SELECT posts.post_id,
       users.username,
       post_photos.photo_url,
       posts.content,
       get_post_likes(posts.post_id)          AS likes_count,
       get_post_comments_count(posts.post_id) AS comments_count,
       posts.created_at
FROM posts
         JOIN users ON posts.user_id = users.user_id
         LEFT JOIN post_photos ON posts.post_id = post_photos.post_id
ORDER BY posts.created_at DESC;

SELECT * FROM posts_information;

-- Представлення всіх друзів, які чекають на підтвердження запиту
CREATE VIEW waited_friends AS
SELECT users.username,
       friends.status,
       friends.created_at
FROM friends
         JOIN users ON friends.user_id1 = users.user_id
WHERE friends.status = 'pending'
ORDER BY users.username;

SELECT * FROM waited_friends;

-- Представлення всіх непрочитаних повідомлень
CREATE VIEW unread_messages AS
SELECT users.username,
       notifications.message,
    notifications.created_at
FROM notifications
         JOIN users ON notifications.user_id = users.user_id
WHERE notifications.is_read = FALSE;

SELECT * FROM unread_messages;

-- Представлення кожного користувача з кількістю друзів
CREATE VIEW users_friends_count AS
SELECT users.username,
       COUNT(friends.friendship_id) AS friends_count
FROM users
         LEFT JOIN friends ON users.user_id = friends.user_id1
WHERE friends.status = 'accepted'
GROUP BY users.username
ORDER BY friends_count DESC;

SELECT * FROM users_friends_count;

-- Представлення користувачів з їх профілями
CREATE VIEW users_information AS
SELECT profiles.profile_picture_url,
       users.username,
       users.email,
       profiles.bio,
       profiles.location,
       users.birth_date
FROM users
         JOIN profiles ON users.user_id = profiles.user_id
WHERE profiles.visibility = 'public';

SELECT * FROM users_information;