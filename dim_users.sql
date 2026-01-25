-- User dimension: one row per user with stable attributes
CREATE OR REPLACE VIEW analytics.dim_users AS
SELECT
  user_id,

  -- Attributes taken as they appear; dataset is consistent enough
  max(country) AS country,
  max(level_of_education) AS level_of_education,
  max(gender) AS gender,
  max(year_of_birth) AS year_of_birth,
  max(roles) AS roles

FROM stg.stg_course_user_engagement
WHERE user_id IS NOT NULL
GROUP BY user_id;
