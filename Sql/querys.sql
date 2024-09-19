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
-------------------------------------------ANASTASIYA-------------------------------------

-- Creating sales table [Done by Anastasiya]
CREATE TABLE sales (
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


-- Cleaned the table to remove the strings wihtout data to get more clear data
  DELETE FROM sales
WHERE production_budget IS NULL
OR worldwide_box_office IS NULL;


--This query lets analyze movie data by extracting information 
--on the average production budget, metascore, 
--and worldwide box office grouped by the release month. 
    
        SELECT 
    EXTRACT(MONTH FROM m.reldate) AS release_month,  -- Extracting the month from the release date
    ROUND(AVG(s.production_budget), 2) AS avg_production_budget,  -- Average production budget
    ROUND(AVG(m.metascore), 2) AS avg_metascore,  -- Average metascore
    ROUND(AVG(s.worldwide_box_office), 2) AS avg_box_office  -- Average worldwide box office
FROM
    sales s
INNER JOIN
    movies m
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
    ------------------------------------------END BY ANASTASIYA-----------------------------

    

---------------------------------------------------------------------CODE BY Anastasia -----------------------------------------------------------------------------------

-- Please, run this first and upload the table(sales.csv is attached in the repository). Then, run the rest of the code.
-- We change in excel the variable name of year to release_year,avg run per theatre to avg_run_per_theatre
-- Create the 'sales' table with various columns including the primary key 'url'

CREATE TABLE sales (
    url VARCHAR (255),			                  -- URL
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

---------------------------------------------------------------------END CODE BY Anastasia -----------------------------------------------------------------------------------

---------------------------------------------------------------------CODE BY David Tapia-----------------------------------------------------------------------------------


-- Delete rows where 'worldwide_box_office' and 'production_budget' are both empty or null
DELETE FROM sales
WHERE (worldwide_box_office IS NULL OR worldwide_box_office = '')
OR (production_budget IS NULL OR production_budget = '');


-- Check if we have unnecessary spaces before or after any value
SELECT * FROM sales WHERE
    url LIKE ' %' OR url LIKE '% ' OR
    title LIKE ' %' OR title LIKE '% ' OR
    genre LIKE ' %' OR genre LIKE '% ' OR
    worldwide_box_office LIKE ' %' OR worldwide_box_office LIKE '% ' OR
    production_budget LIKE ' %' OR production_budget LIKE '% ' OR
    opening_weekend LIKE ' %' OR opening_weekend LIKE '% ' OR
    theatre_count LIKE ' %' OR theatre_count LIKE '% ' OR
    avg_run_per_theatre LIKE ' %' OR avg_run_per_theatre LIKE '% ' OR
    runtime LIKE ' %' OR runtime LIKE '% ' OR
    creative_type LIKE ' %' OR creative_type LIKE '% ' OR
    release_date LIKE ' %' OR release_date LIKE '% ' OR
    keywords LIKE ' %' OR keywords LIKE '% ';
   
-- We confirmed that there are values that need to be trimmed, so we trimmed the table sales

UPDATE sales
SET
    url = LOWER(TRIM(url)),
    title = LOWER(TRIM(title)),
    genre = LOWER(TRIM(genre)),
    worldwide_box_office = LOWER(TRIM(worldwide_box_office)),
    production_budget = LOWER(TRIM(production_budget)),
    opening_weekend = LOWER(TRIM(opening_weekend)),
    theatre_count = LOWER(TRIM(theatre_count)),
    avg_run_per_theatre = LOWER(TRIM(avg_run_per_theatre)),
    runtime = LOWER(TRIM(runtime)),
    creative_type = LOWER(TRIM(creative_type)),
    release_date = LOWER(TRIM(release_date)),
    keywords = LOWER(TRIM(keywords));
   
   
-- Check agan if we have unnecessary spaces before or after any value
SELECT * FROM sales WHERE
    url LIKE ' %' OR url LIKE '% ' OR
    title LIKE ' %' OR title LIKE '% ' OR
    genre LIKE ' %' OR genre LIKE '% ' OR
    worldwide_box_office LIKE ' %' OR worldwide_box_office LIKE '% ' OR
    production_budget LIKE ' %' OR production_budget LIKE '% ' OR
    opening_weekend LIKE ' %' OR opening_weekend LIKE '% ' OR
    theatre_count LIKE ' %' OR theatre_count LIKE '% ' OR
    avg_run_per_theatre LIKE ' %' OR avg_run_per_theatre LIKE '% ' OR
    runtime LIKE ' %' OR runtime LIKE '% ' OR
    creative_type LIKE ' %' OR creative_type LIKE '% ' OR
    release_date LIKE ' %' OR release_date LIKE '% ' OR
    keywords LIKE ' %' OR keywords LIKE '% ';
   
   
   
-- Drop the column 'column9' from the 'sales' table
ALTER TABLE sales
DROP COLUMN column9;

-- Add the 'title_year' column to 'sales_v25' by concatenating 'title' and 'release_year'
ALTER TABLE sales
ADD title_year VARCHAR(10000);

-- Update 'title_year' with the concatenated values of 'title' and 'release_year'
UPDATE sales
SET title_year = CONCAT(title, '_', release_year);


-- Select all rows where 'title_year' has duplicates
SELECT *
FROM sales
WHERE title_year IN (
    SELECT title_year
    FROM sales
    GROUP BY title_year
    HAVING COUNT(*) > 1
);

-- Set 'title_year' as the primary key
ALTER TABLE sales
ADD PRIMARY KEY (title_year);


--show the table sales
SELECT *
FROM sales
;

---------------------------------------------------------------------END CODE BY DAVID TAPIA-----------------------------------------------------------------------------------

---------------------------------------------------------------------CODE BY MEES -----------------------------------------------------------------------------------


-- Create the 'expert' table with various columns for text analysis and metadata
CREATE TABLE expert_v0 (
    url VARCHAR(255),           -- URL of the review or article
    idvscore FLOAT,             -- Individual score of the review
    reviewer VARCHAR(255),      -- Name of the reviewer
    dateP VARCHAR(255),         -- Date of the review (initially as a string)
    Rev TEXT,                   -- Review content
    WC INT,                     -- Word count
    Analytic FLOAT,             -- Analytical score
    Clout FLOAT,                -- Clout score
    Authentic FLOAT,            -- Authenticity score
    Tone FLOAT,                 -- Tone score
    WPS FLOAT,                  -- Words per sentence
    Sixltr INT,                 -- Six-letter word count
    Dic INT,                    -- Dictionary word count
    -- Various other linguistic features and metrics
    function FLOAT,
    pronoun FLOAT,
    ppron FLOAT,
    i FLOAT,
    we FLOAT,
    you FLOAT,
    shehe FLOAT,
    they FLOAT,
    ipron FLOAT,
    article FLOAT,
    prep FLOAT,
    auxverb FLOAT,
    adverb FLOAT,
    conj FLOAT,
    negate FLOAT,
    verb FLOAT,
    adj FLOAT,
    compare FLOAT,
    interrog FLOAT,
    number FLOAT,
    quant FLOAT,
    affect FLOAT,
    posemo FLOAT,
    negemo FLOAT,
    anx FLOAT,
    anger FLOAT,
    sad FLOAT,
    social FLOAT,
    family FLOAT,
    friend FLOAT,
    female FLOAT,
    male FLOAT,
    cogproc FLOAT,
    insight FLOAT,
    cause FLOAT,
    discrep FLOAT,
    tentat FLOAT,
    certain FLOAT,
    differ FLOAT,
    percept FLOAT,
    see FLOAT,
    hear FLOAT,
    feel FLOAT,
    bio FLOAT,
    body FLOAT,
    health FLOAT,
    sexual FLOAT,
    ingest FLOAT,
    drives FLOAT,
    affiliation FLOAT,
    achieve FLOAT,
    power FLOAT,
    reward FLOAT,
    risk FLOAT,
    focuspast FLOAT,
    focuspresent FLOAT,
    focusfuture FLOAT,
    relativ FLOAT,
    motion FLOAT,
    space FLOAT,
    time FLOAT,
    work FLOAT,
    leisure FLOAT,
    home FLOAT,
    money FLOAT,
    relig FLOAT,
    death FLOAT,
    informal FLOAT,
    swear FLOAT,
    netspeak FLOAT,
    assent FLOAT,
    nonflu FLOAT,
    filler FLOAT,
    AllPunc FLOAT,
    Period FLOAT,
    Comma FLOAT,
    Colon FLOAT,
    SemiC FLOAT,
    QMark FLOAT,
    Exclam FLOAT,
    Dash FLOAT,
    Quote FLOAT,
    Apostro FLOAT,
    Parenth FLOAT,
    OtherP FLOAT
);

---------------------------------------------------------------------END CODE BY MEES -----------------------------------------------------------------------------------
---------------------------------------------------------------------CODE BY DAVID TAPIA -----------------------------------------------------------------------------------


-- Add a new column 'title' to store the movie title extracted from the URL
ALTER TABLE expert_v0 ADD COLUMN title VARCHAR(255);

-- Extract the movie title from the URL by splitting on '/' and taking the 5th part
UPDATE expert_v0 SET title = SPLIT_PART(url, '/', 5);

-- Convert the extracted title to lowercase and replace hyphens with spaces
UPDATE expert_v0 SET title = LOWER(REPLACE(title, '-', ' '));

-- Clean up the 'dateP' column by removing unwanted quotes and whitespace
UPDATE expert_v0 SET dateP = REPLACE(REPLACE(dateP, '"', ''), '''', '');
UPDATE expert_v0 SET dateP = TRIM(dateP);

-- Set invalid date values to NULL (e.g., 'None', 'NULL', or empty strings)
UPDATE expert_v0 SET dateP = NULL WHERE dateP IN ('None', 'NULL', '');

-- Convert valid date strings to the DATE format (from 'Mon DD, YYYY')
UPDATE expert_v0 SET dateP = TO_DATE(dateP, 'Mon DD, YYYY') WHERE dateP IS NOT NULL;

-- Add a new column 'new' to store the extracted year from 'dateP'
ALTER TABLE expert_v0 ADD COLUMN new INT;
UPDATE expert_v0 SET new = EXTRACT(YEAR FROM CAST(dateP AS DATE));

-- Add a new column 'avg_idvscore' to store the average score per URL
ALTER TABLE expert_v0 ADD COLUMN avg_idvscore FLOAT;

-- Calculate the average 'idvscore' for each URL and update the 'avg_idvscore' column
WITH avg_scores AS (
    SELECT url, AVG(idvscore) AS avg_idvscore
    FROM expert_v0
    GROUP BY url
)
UPDATE expert_v0
SET avg_idvscore = avg_scores.avg_idvscore
FROM avg_scores
WHERE expert_v0.url = avg_scores.url;

-- Add a new column 'min_year' to store the minimum year of reviews for each URL
ALTER TABLE expert_v0 ADD COLUMN min_year INT;

-- Calculate the minimum year of the reviewers/ which is probably the realeased date  from 'dateP' for each URL and update 'min_year'
WITH min_years AS (
    SELECT url, MIN(EXTRACT(YEAR FROM CAST(dateP AS DATE))) AS min_year
    FROM expert_v0
    GROUP BY url
)
UPDATE expert_v0
SET min_year = min_years.min_year
FROM min_years
WHERE expert_v0.url = min_years.url;

-- Create a new table 'expert' with required information
-- this includes the URL, title, average idvscore, minimum year, and a concatenated title_year column

CREATE TABLE expert AS
SELECT url, 
       SPLIT_PART(LOWER(REPLACE(SPLIT_PART(url, '/', 5), '-', ' ')), '/', 1) AS title,
       AVG(idvscore) AS avg_idvscore, 
       AVG(min_year) AS avg_min_year,
       CONCAT(SPLIT_PART(LOWER(REPLACE(SPLIT_PART(url, '/', 5), '-', ' ')), '/', 1), '_', ROUND(AVG(min_year))) AS title_year
FROM expert_v0
GROUP BY url;

-- Alter the table to add 'title_year' as the primary key
ALTER TABLE expert
ADD CONSTRAINT pk_title_year PRIMARY KEY (title_year);

---------------------------------------------------------------------END CODE BY David Tapia-----------------------------------------------------------------------------------


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



    ---------------------------------------------------------------------CODE BY DAVID TAPIA -----------------------------------------------------------------------------------
-- Create a new table 'expert_sales' that joins data from 'sales' and "expert"
-- This query joins the sales and expert tables based on title and release year

CREATE TABLE expert_sales AS
SELECT 
    s.url,                              -- URL of the movie or review
    s.title AS sales_title,              -- Title of the movie from the 'sales' table
    s.genre,                             -- Genre of the movie
    s.worldwide_box_office,              -- Worldwide box office earnings
    s.production_budget,                 -- Production budget of the movie
    s.opening_weekend,                   -- Opening weekend revenue
    s.theatre_count,                     -- Number of theatres it was shown in
    s.avg_run_per_theatre,               -- Average run per theatre
    s.runtime,                           -- Duration of the movie
    s.creative_type,                     -- Type of creative content (e.g., animation, live-action)
    s.release_year,                      -- Release year of the movie

    -- Columns from the 'expert' table
    e.title AS movie_title,              -- Title from the 'expert' table for verification
    e.avg_idvscore,                      -- Average individual score from the 'expert' table
    e.avg_min_year,                      -- Average minimum year of reviews from 'expert'
    e.title_year                         -- Concatenated title and year (e.g., 'movie_title_year')
    
-- Data source 1: 'sales' table (movie sales data)
FROM sales s

-- Join with 'expert' table (movie expert data)
JOIN expert e
ON LOWER(s.title_year) = LOWER(e.title_year);  -- Match on title and year (case-insensitive)

    ---------------------------------------------------------------------END CODE DAVID TAPIA -----------------------------------------------------------------------------------
