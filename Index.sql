EXPLAIN ANALYZE
SELECT u.user_id,
       p.profile_picture_url,
       u.username,
       u.full_name,
       u.birth_date,
       p.bio
FROM users u
         LEFT JOIN profiles p ON u.user_id = p.user_id
GROUP BY u.user_id, p.profile_picture_url, u.username, u.full_name, u.birth_date, p.bio
HAVING EXTRACT(YEAR FROM AGE(u.birth_date)) > 18;

CREATE INDEX idx_users_birth_date ON users (birth_date);
CREATE INDEX idx_profiles_user_id ON profiles (user_id);

DROP INDEX idx_users_birth_date;
DROP INDEX idx_profiles_user_id;