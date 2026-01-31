-- Raw data table for course user engagement
-- See README.md for complete setup and data loading instructions

CREATE TABLE IF NOT EXISTS raw.course_user_engagement (
index TEXT,
random TEXT,
course_id TEXT,
userid_di TEXT,
registered TEXT,
viewed TEXT,
explored TEXT,
certified TEXT,
final_cc_cname_di TEXT,
loe_di TEXT,
yob TEXT,
gender TEXT,
grade TEXT,
start_time_di TEXT,
last_event_di TEXT,
nevents TEXT,
ndays_act TEXT,
nplay_video TEXT,
nchapter TEXT,
nforum_posts TEXT,
roles TEXT,
incomplete_flag TEXT
);
