---------------------------------------------------------------------These are the SQL queries for Group 2-------------------------------------------------------------------


--Our group is composed by: Mandi, David, Anastasia, Zakaria and Mees


---GROUP TASKS---
--We shared tasks between us to clean, create and upload tables. Below are different codes for creating the tables
--Further explanation about how the datasets were cleaned and processed in the research document


-- Creating movie table [Done by Mandi]
CREATE TABLE Movies (
    URL VARCHAR(255) PRIMARY KEY,  -- URL of the movie's page
    Title VARCHAR(255),  -- Movie title
    Studio VARCHAR(255),  -- Studio name
    Rating VARCHAR(50),  -- Movie rating (e.g., PG-13, R)
    Runtime VARCHAR(50),  -- Duration of the movie in minutes
    MovieCast TEXT,  -- Cast of the movie
    Director VARCHAR(255),  -- Director of the movie
    Genre VARCHAR(255),  -- Movie genre
    Summary TEXT,  -- Short summary of the movie
    Awards TEXT,  -- Awards or accolades
    Metascore INT,  -- Metascore rating
    UserScore DECIMAL(3, 1),  -- User score (float with 1 decimal place)
    RelDate DATE  -- Release date of the movie
);

-- Creating Rating table [Done by Mandi]
CREATE TABLE Rating (
    URL VARCHAR(255) PRIMARY KEY,  -- URL of the movie, same as in Movies table
    Rating VARCHAR(50),  -- Movie rating (e.g., PG-13, R)
    FOREIGN KEY (URL) REFERENCES Movies(URL)  -- Ensures that the URL exists in the Movies table
);


---------------------------------------------------------------------CODE BY Mandi Disha-----------------------------------------------------------------------------------


--The database is created and now we are going to analyze what is the relationship
--between production budgets and userscore based on Rating to see how it influences movie box_office
-------------------------------------------------------------------------------------


--Step 1: Creating a subquey to rank movies based on box office per each rating 

CREATE TEMP TABLE movie_analysis AS
	SELECT
    m.rating,  -- Grouping by movie rating
    COUNT(s.title) AS movie_count,
    ROUND(AVG(s.production_budget), 2) AS avg_production_budget,  -- Average production budget rounded to 2 decimal places
    ROUND(AVG(m.userscore), 2) AS avg_userscore,  -- Average metascore rounded to 2 decimal places
    ROUND(AVG(s.worldwide_box_office), 2) AS avg_box_office,  -- Average box office rounded to 2 decimal places
    ROUND((AVG(s.worldwide_box_office) - AVG(s.production_budget)) / AVG(s.production_budget) * 100, 2) AS avg_profit_percentage  -- Profit percentage
FROM
    sales_v20 s
JOIN
    movies m
ON
    s.title = m.title
AND
    s.release_year = EXTRACT(YEAR FROM m.reldate)
WHERE
    s.production_budget IS NOT NULL  -- Ensuring we only calculate for movies with known budgets
AND
    m.userscore IS NOT NULL -- Ensuring we only calculate for movies with known Metascores
GROUP BY
    m.rating  -- Grouping the results by rating
ORDER BY
    avg_production_budget DESC,  -- Ordering by the average production budget (descending)
    avg_userscore DESC,  -- Ordering by the average metascore (descending)
    avg_box_office DESC;  -- Ordering by the average box office (descending)

--NEXT STEP: We'll use Python to run a correlation analysis on the table, looking for connections between box office sales,
--userscore ratings, and production budgets. This research will assist us in showing the extent to which 
--film budgets and user reception influence box office success.


--To run this code to preview the research table stored in a temporary table
SELECT * FROM movie_analysis
---------------------------------------------------------------------END CODE BY Mandi Disha


-- Creating sales table [Done by Anastasiya]
CREATE TABLE sales_v20 (
    url VARCHAR (255) PRIMARY KEY,                -- Primary key for the table
    title VARCHAR (10000),                        -- Title of the movie (up to 10,000 characters)
    genre VARCHAR (50),                           -- Genre of the movie (up to 50 characters)
    worldwide_box_office VARCHAR (50),            -- Worldwide box office earnings
    production_budget VARCHAR (50),               -- Production budget of the movie
    opening_weekend VARCHAR (50),                 -- Opening weekend revenue
    theatre_count VARCHAR (50),                   -- Number of theatres it was shown in
    avg_run_per_theatre VARCHAR (50),             -- Average run per theatre
    runtime VARCHAR (50),                         -- Duration of the movie
    creative_type VARCHAR (100),                  -- Type of creative content (e.g., animation, live-action)
    release_year INT,                             -- Release year of the movie
    release_date VARCHAR (100),                   -- Release date of the movie
    keywords VARCHAR(500)                         -- Keywords associated with the movie
);


-- I cleaned the table to remove empty/null strings to get more clear data
 DELETE FROM sales_v20
WHERE production_budget IS NULL
OR production_budget = ''
OR worldwide_box_office IS NULL
OR worldwide_box_office = '';

--s
    
        SELECT 
    EXTRACT(MONTH FROM m.reldate) AS release_month,  -- Extracting the month from the release date
    ROUND(AVG(s.production_budget), 2) AS avg_production_budget,  -- Average production budget
    ROUND(AVG(m.metascore), 2) AS avg_metascore,  -- Average metascore
    ROUND(AVG(s.worldwide_box_office), 2) AS avg_box_office  -- Average worldwide box office
FROM
    sales_v20 s
INNER JOIN
    movies2 m
ON
    s.title = m.title
AND
    s.release_year = EXTRACT(YEAR FROM m.reldate)
WHERE
    s.production_budget IS NOT NULL  -- Only calculate for movies with known budgets
AND
    m.metascore IS NOT NULL  -- Only calculate for movies with known metascores
GROUP BY
    EXTRACT(MONTH FROM m.reldate)  -- Grouping by the month
ORDER BY

    avg_production_budget DESC,  -- Then by production budget (descending)
    avg_metascore ,
    release_month ;