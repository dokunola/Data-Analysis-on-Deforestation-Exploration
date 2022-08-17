DROP VIEW forestation;
CREATE VIEW forestation AS 
SELECT f.country_name  "Country Name",
       f.country_code  "Country Code", 
       f.year, 
       f.forest_area_sqkm  "Forest_Area",
       l.total_area_sq_mi "Area Sq_mi", 
       l.total_area_sq_mi * 2.59 "Total Area_sqkm",
       r.region "Region", 
       r.income_group "Income Group",
       100 * (f.forest_area_sqkm * 100 /(l.total_area_sq_mi * 259))  "Forest Percentage"
FROM forest_area f
JOIN land_area l
ON f.country_code = l.country_code
AND f.year = l.year
JOIN regions r
ON l.country_code = r.country_code;

SELECT *
FROM forestation;


/* GLOBAL SITUATION Question
What was the change (in sq km) in the forest area of the world from 1990 to 2016? 
*/

SELECT SUM("Forest Area")
FROM forestation
WHERE "Year" = 2016
AND "Region" = 'World';

/* GLOBAL SITUATION Question
What was the change (in sq km) in the forest area of the world from 1990 to 2016? 
*/

SELECT (f1."Forest_Area" - f2."Forest_Area") AS "Forest_Area_Change"
FROM    forestation f1, 
        forestation f2
WHERE 
    f1.year = 1990 
AND f1."Region" = 'World'
AND f2.year = 2016
AND f2."Region" = 'World';

/* What was the percent change in forest area of the world between 1990 and 2016? */

SELECT (f1."Forest_Area" - f2."Forest_Area") * 100/f1."Forest_Area" 
AS  "Forest_Percent_Change"
FROM    forestation f1, 
        forestation f2
WHERE 
    f1.year = 1990 
AND f1."Region" = 'World'
AND f2.year = 2016
AND f2."Region" = 'World';

/* Output : 3.20824258980244 */

/* 
If you compare the amount of forest area lost between 1990 and 2016, 
to which country's total area in 2016 is it closest to?
*/

SELECT "Country Name", "Total_Area_Sqkm"
FROM forestation
WHERE year = 2016 AND
ORDER BY "Total_Area_Sqkm" DESC;

/* REGIONAL OUTLOOK */

/* What was the percent forest of the entire world in 2016? */ 
SELECT "Forest_Area" * 100/"Total Area_sqkm" AS "Percent_Forest_2016"
FROM forestation
WHERE year = 2016
AND "Country Name" = 'World';

-- 31.3755709643095

/* Which region had the HIGHEST percent forest in 2016 ROUND to 2 decimal places*/

SELECT "Region",
ROUND(CAST(forest_percent AS numeric), 2)
FROM
        (SELECT "Region", SUM("Forest_Area")* 100/SUM("Total Area_sqkm") AS forest_percent
        FROM forestation
        WHERE year = 2016
        GROUP BY "Region") sub
ORDER BY forest_percent DESC
LIMIT 5;

/* Which region had the LOWEST percent forest in 2016 ROUND to 2 decimal places*/

SELECT "Region",
ROUND(CAST(forest_percent AS numeric), 2) AS percent
FROM
        (SELECT "Region", SUM("Forest_Area")* 100/SUM("Total Area_sqkm") AS forest_percent
        FROM forestation
        WHERE year = 2016
        GROUP BY "Region") sub
ORDER BY forest_percent 
LIMIT 1;

/*What was the percent forest of the entire world in 1990?*/

SELECT "Forest_Area" * 100/"Total Area_sqkm" AS "Percent_Forest_1990"
FROM forestation
WHERE year = 1990
AND "Country Name" = 'World';

/*Which region had the HIGHEST percent forest in 1990 */
SELECT "Region",
ROUND(CAST(forest_percent AS numeric), 2) AS Percent
FROM
        (SELECT "Region", SUM("Forest_Area")* 100/SUM("Total Area_sqkm") AS forest_percent
        FROM forestation
        WHERE year = 1990
        GROUP BY "Region") sub
ORDER BY forest_percent DESC
LIMIT 1;

/*Which region had the LOWEST percent forest in 1990 */

SELECT "Region",
ROUND(CAST(forest_percent AS numeric), 2) AS Percent
FROM
        (SELECT "Region", SUM("Forest_Area")* 100/SUM("Total Area_sqkm") AS forest_percent
        FROM forestation
        WHERE year = 1990
        GROUP BY "Region") sub
ORDER BY forest_percent
LIMIT 1;

/* Create a table that shows the Regions and their percent forest area 
(sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km) */

SELECT "Region", ROUND(CAST((forest_region_1990/region_1990) * 100 AS NUMERIC), 2)
        AS percent_forest_1990,
        ROUND(CAST((forest_region_2016/region_2016) * 100 AS NUMERIC), 2)
        AS percent_forest_2016


FROM(SELECT SUM(f1."Forest_Area") forest_region_1990,
                SUM(f1."Total Area_sqkm") region_1990,
                f1."Region",
                SUM(f2."Forest_Area") forest_region_2016,
                SUM(f2."Total Area_sqkm") region_2016

                FROM    forestation f1,
                        forestation f2
                WHERE   f1.year = '1990'
                AND     f1."Country Name" NOT LIKE 'World'
                AND     f2.year = '2016'
                AND     f2."Country Name" NOT LIKE 'World'
                AND f1."Region" = f2."Region"
                GROUP BY f1."Region") percent_region
ORDER BY percent_forest_1990 DESC;

/* COUNTRY-LEVEL DETAIL */


WITH 
tab1 AS(SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 1990),

 tab2 AS
        (SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 2016)

SELECT tab1."Region",
        tab1."Country Name",
        tab1."Forest_Area" forest_1990,
        tab2."Forest_Area" forest_2016,
        ROUND(CAST((tab2."Forest_Area" - tab1."Forest_Area")AS numeric), 2) AS forest_area_difference,
        ROUND(CAST(((tab2."Forest_Area" - tab1."Forest_Area")*100/tab1."Forest_Area")AS numeric), 2) AS increase_percent

FROM tab1
JOIN tab2
ON tab1."Country Name" = tab2."Country Name"
WHERE tab2."Forest_Area" > tab1."Forest_Area"
ORDER BY increase_percent

/* Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
What was the difference in forest area for each? */

WITH 
tab1 AS(SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 1990),

 tab2 AS
        (SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 2016)

SELECT tab1."Region",
        tab1."Country Name",
        tab1."Forest_Area" forest_1990,
        tab2."Forest_Area" forest_2016,
        ROUND(CAST((tab2."Forest_Area" - tab1."Forest_Area")AS numeric), 2) AS forest_area_difference,
        ROUND(CAST(((tab2."Forest_Area" - tab1."Forest_Area")*100/tab1."Forest_Area")AS numeric), 2) AS increase_percent

FROM tab1
JOIN tab2
ON tab1."Country Name" = tab2."Country Name"
WHERE tab2."Forest_Area" < tab1."Forest_Area"
AND tab1."Region" =! 'World'

ORDER BY forest_area_difference DESC
LIMIT 5;

/* --------------------------------- */

SELECT f1.country_name country,
        (f1.forest_area_sqkm  - f2.forest_area_sqkm)AS forest_difference
FROM forest_area f1
JOIN forest_area f2
ON (f1.year = '2016' AND f2.year = '1990')
AND f1.country_name = f2.country_name
ORDER BY forest_difference DESC;

China -------- 527229.062
United States -- 79200

SELECT f1.country_name country,
        100.0 * (f1.forest_area_sqkm  - f2.forest_area_sqkm) / f2.forest_area_sqkm AS percent_difference
FROM forest_area f1
JOIN forest_area f2
ON (f1.year = '2016' AND f2.year = '1990')
AND f1.country_name = f2.country_name
ORDER BY percent_difference DESC;

/*Which 5 countries saw the largest percent decrease in forest 
rea from 1990 to 2016? What was the percent change to 2 
decimal places for each?
*/
WITH 
tab1 AS(SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 1990),

 tab2 AS
        (SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 2016)

SELECT tab1."Region",
        tab1."Country Name",
        tab1."Forest_Area" forest_1990,
        tab2."Forest_Area" forest_2016,
        ROUND(CAST((tab1."Forest_Area" - tab2."Forest_Area")AS numeric), 2) AS forest_area_difference,
        ROUND(CAST(((tab1."Forest_Area" - tab2."Forest_Area")*100/tab1."Forest_Area")AS numeric), 2) AS decrease_percent

FROM tab1
JOIN tab2
ON tab1."Country Name" = tab2."Country Name"
WHERE tab2."Forest_Area" < tab1."Forest_Area"
AND tab1."Region" != 'World'
ORDER BY forest_area_difference DESC
LIMIT 5;

/*Which 5 countries saw the largest percent decrease IN forest area FROM 1990 to 2016?
What was the percent change to 2 decimal places for each?
*/
WITH 
tab1 AS(SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 1990),

 tab2 AS
        (SELECT "Region",
                "Country Name",
                "Forest_Area"
        FROM forestation
        WHERE year = 2016)

SELECT tab1."Region",
        tab1."Country Name",
        tab1."Forest_Area" forest_1990,
        tab2."Forest_Area" forest_2016,
        ROUND(CAST((tab1."Forest_Area" - tab2."Forest_Area")AS numeric), 2) AS forest_area_difference,
        ROUND(CAST(((tab1."Forest_Area" - tab2."Forest_Area")*100/tab1."Forest_Area")AS numeric), 2) AS decrease_percent

FROM tab1
JOIN tab2
ON tab1."Country Name" = tab2."Country Name"
WHERE tab2."Forest_Area" < tab1."Forest_Area"
AND tab1."Region" != 'World'
ORDER BY decrease_percent DESC
LIMIT 5;

/*If countries were grouped by percent forestation in quartiles, 
which group had the most countries in it in 2016? */

SELECT distinct(quartiles), COUNT("Country Name") OVER (PARTITION BY quartiles)
FROM (SELECT "Country Name",
CASE WHEN "Forest Percentage" <= 25 THEN '0-25%'
WHEN "Forest Percentage" <= 75 AND "Forest Percentage" > 50 THEN '50-75%'
WHEN "Forest Percentage" <= 50 AND "Forest Percentage" > 25 THEN '25-50%'
ELSE '75-100%'
END AS quartiles 
FROM forestation
WHERE "Forest Percentage" IS NOT NULL AND year = 2016) sub;



/* List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016. */
SELECT "Country Name",
       "Region",
       "Forest Percentage"
FROM forestation
WHERE "Forest Percentage"> 75
AND "Forest Percentage" IS NOT NULL
AND year = 2016
ORDER BY "Forest Percentage" DESC;

/* How many countries had a percent forestation higher than the United States in 2016?*/
SELECT COUNT("Country Name")
FROM forestation
WHERE year = 2016
AND "Forest Percentage" >
        (SELECT "Forest Percentage"
        FROM forestation
        WHERE "Country Name" = 'United States'
        AND year = 2016);


/*Review 
/*If countries were grouped by percent forestation in quartiles, 
which group had the most countries in it in 2016? */

WITH tab1 AS 
(SELECT *
FROM forestation
WHERE year = 2016
AND "Region" NOT LIKE 'World'
AND "Forest Percentage" IS NOT NULL),

tab2 AS 
(SELECT *,
CASE 
WHEN "Forest Percentage" >= 75 THEN '75 - 100%'
WHEN "Forest Percentage" > 50 AND "Forest Percentage" <= 75 THEN '50-75%'
WHEN "Forest Percentage" > 25 AND "Forest Percentage" <= 50 THEN '25-50%'
ELSE '0-25%'
END AS Quartile
FROM tab1)

SELECT Quartile , COUNT(*) AS "Number of Countries"
FROM tab2
GROUP BY Quartile;

