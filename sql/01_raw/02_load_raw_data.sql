/*
Raw data ingestion

This dataset was loaded using the psql client with the \copy command
to avoid Windows filesystem permission issues with server-side COPY.

Command used (run in SQL Shell / psql):

\copy raw.course_user_engagement
FROM 'C:/Users/huang_pc/PC-Only-Files/GitHub-Repos/course-engagement-analytics-warehouse/data/raw/Courses.csv'
DELIMITER ','
CSV HEADER;


Load performed once. Raw layer is immutable.
*/

