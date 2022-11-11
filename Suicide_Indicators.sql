
-- Suicide Data Exploration


SELECT *
FROM Myproject..suicides


SELECT country, year, sex, age, population, suicides_no
FROM Myproject..suicides
ORDER BY 1,2


-- Looking at Suicide Numbers per 100k Population
-- Shows a Rate at Which People Commit Suicide per 100k

SELECT country, year, sex, age, population, suicides_no, ROUND(suicides_no/(population/100000),2) AS SuicideRate
FROM Myproject..suicides
ORDER BY 1,2



-- Looking at the Suicide Rate in the United States

SELECT country, year, sex, age, population, suicides_no, ROUND(suicides_no/(population/100000),2)
AS SuicideRate
FROM Myproject..suicides
WHERE country LIKE '%states%'
ORDER BY year



-- The Maximum of the Suicide Numbers based on the Sex in the United states

SELECT sex, max(suicides_no) AS SuicideSum
FROM Myproject..suicides
WHERE country LIKE '%states%'
GROUP BY sex



-- The Trend of Suicide Rate in the United States
-- Shows the Time-Series of the Suicide Rate (per 100,000K) in the Period (1985-2015)

SELECT country, year, SUM(population) AS Allpopulation, SUM(suicides_no) AS AllSuicides, ROUND(SUM(suicides_no)/SUM(population/100000),2)
AS SuicideRate
FROM Myproject..suicides
GROUP BY country, year
HAVING country LIKE '%states%'
ORDER BY year



-- The Trend of Suicide Rate in the World
-- Shows the Time-Series of the Suicide Rate (per 100,000K)in the Period (1985-2015)
-- There are Different Numbers of Countries in Different Years. That's Why the Sumpopulation Does not Show the World's Population

SELECT year, SUM(population) AS Allpopulation, SUM(suicides_no) AS AllSuicides, ROUND(SUM(suicides_no)/SUM(population/100000),2)
AS SuicideRate
FROM Myproject..suicides
GROUP BY year
ORDER BY year



-- The Highest Suicide Rate (per 100,000K) in the United States during the Period (1985-2015)

SELECT TOP 1 country, year, SUM(population) AS Sumpopulation, SUM(suicides_no) AS SumSuicide, ROUND(SUM(suicides_no)/SUM(population/100000),2)
AS SuicideRate
FROM Myproject..suicides
GROUP BY country, year
HAVING country LIKE '%states%'
ORDER BY SuicideRate DESC



-- The Highest Suicide Rate (per 100,000K) in the World during the Period (1985-2015)

SELECT TOP 1 year, SUM(population) AS AllPopulation, SUM(suicides_no) AS AllSuicides, ROUND(SUM(suicides_no)/SUM(population/100000),2)
AS SuicideRate
FROM Myproject..suicides
GROUP BY year
ORDER BY SuicideRate DESC


-- The Country with the Highest Suicide Rate in the World during the Period (1985-2015)

SELECT TOP 1 country, year, SUM(population) AS AllPopulation, SUM(suicides_no) AS AllSuicides, ROUND(SUM(suicides_no)/SUM(population/100000),2)
AS SuicideRate
FROM Myproject..suicides
GROUP BY country, year
ORDER BY SuicideRate DESC



-- Comparing Suicide Rate in the Countries with the Highest Rate in the World during the Period (1985-2015)
-- The Highest Sucicide Rate was 15.3 in the aboved mention period
-- Shows the Rate Condition of Countries in 1995 Comparing with the Suicide Rate in that Year, Which was the Highest One

SELECT country, year, SUM(population) AS AllPopulation, SUM(suicides_no) AS AllSuicides, ROUND(SUM(suicides_no)/SUM(population/100000),2)
AS SuicideRate
	,CASE
	WHEN ROUND(SUM(suicides_no)/SUM(population/100000),2) >= 15.3 THEN 'High Rate'
	WHEN ROUND(SUM(suicides_no)/SUM(population/100000),2) < 15.3 THEN 'Low Rate'
	END AS RateCondition
FROM Myproject..suicides
GROUP BY country, year
HAVING year = 1995
ORDER BY country



-- Let's Break Things Down Age

SELECT age, SUM(population) AS Sumpopulation, SUM(suicides_no) AS SumSuicide, ROUND(SUM(suicides_no)/SUM(population/100000),2) AS SuicideRate
FROM Myproject..suicides
WHERE year=2014
GROUP BY age 
ORDER BY SuicideRate DESC



-- Let's Break Things Down Sex

SELECT sex, SUM(population) AS Sumpopulation, SUM(suicides_no) AS SumSuicide, ROUND(SUM(suicides_no)/SUM(population/100000),2) AS SuicideRate
FROM Myproject..suicides
GROUP BY sex
ORDER BY SuicideRate DESC



-- Global Numbers
-- The Popluation is NOT Real Because Some Countries are Available in Data
SELECT year, SUM(population) AS Totalpopulation, SUM(suicides_no) AS TotalSuicides, ROUND(SUM(suicides_no)/SUM(population/100000),2) AS SuicideRate
FROM Myproject..suicides
GROUP BY year
ORDER BY 1



SELECT *
FROM Myproject..indicators

-- Looking at GDP in the world

SELECT year, country, avg(gdpcap)
FROM Myproject..indicators
GROUP BY year, country, gdpcap



-- Looking at Suicides Vs GDP (Gross Domestic Product) per Capita and HDI (Human Development Index)

SELECT suic.country, suic.year, suic.population, suic.suicides_no, ind.gdpcap, ind.HDI
FROM Myproject..suicides AS suic
JOIN Myproject..indicators AS ind
	ON suic.country = ind.country
	AND suic.age = ind.age
	AND suic.year=ind.year
	AND suic.sex=ind.sex
ORDER BY suic.country, suic.year



-- Total Sucicide and Total GDP for each Year and each Country

SELECT suic.country, suic.year, suic.age, suic.population, suic.suicides_no, ind.gdpcap, ind.HDI
, SUM(suic.suicides_no) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS TotalSuicides
, ind.gdpcap*SUM(suic.population) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS GDP
FROM Myproject..suicides AS suic
JOIN Myproject..indicators AS ind
	ON suic.country = ind.country
	AND suic.age = ind.age
	AND suic.year=ind.year
	AND suic.sex=ind.sex
ORDER BY suic.country, suic.year



-- CTE

With SuicVSInd (country, year, sex, age, population, suicides_no, HDI, GDPPerYear, SuicideYear)
AS
(
SELECT suic.country, suic.year, suic.sex, suic.age, suic.population, suic.suicides_no, ind.HDI
, ind.gdpcap*SUM(suic.population) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS GDPPerYear
,SUM(suic.suicides_no) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS SuicideYear
FROM Myproject..suicides AS suic
JOIN Myproject..indicators AS ind
	ON suic.country = ind.country
	AND suic.age = ind.age
	AND suic.year=ind.year
	AND suic.sex=ind.sex
)
SELECT *
FROM SuicVSInd
ORDER BY country, year



-- Temporary Table

DROP TABLE IF EXISTS #SuicideIndicators
CREATE TABLE #SuicideIndicators
(
country nvarchar(255),
year float,
sex nvarchar(255),
age nvarchar(255),
population numeric,
suicides_no numeric,
HDI nvarchar(255),
GDPPerYear numeric,
SuicideYear numeric
)

INSERT INTO #SuicideIndicators

SELECT suic.country, suic.year, suic.sex, suic.age, suic.population, suic.suicides_no, ind.HDI
, ind.gdpcap*SUM(suic.population) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS GDPPerYear
,SUM(suic.suicides_no) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS SuicideYear
FROM Myproject..suicides AS suic
JOIN Myproject..indicators AS ind
	ON suic.country = ind.country
	AND suic.age = ind.age
	AND suic.year=ind.year
	AND suic.sex=ind.sex
ORDER BY 1,2

SELECT *
FROM #SuicideIndicators
ORDER BY country, year



-- Creating View for Data Visualizations

Create View SuicideANDIndicators AS

SELECT suic.country, suic.year, suic.sex, suic.age, suic.population, suic.suicides_no, ind.HDI
, ind.gdpcap*SUM(suic.population) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS GDPPerYear
,SUM(suic.suicides_no) OVER (PARTITION BY suic.year ORDER BY suic.country, suic.year) AS SuicideYear
FROM Myproject..suicides AS suic
JOIN Myproject..indicators AS ind
	ON suic.country = ind.country
	AND suic.age = ind.age
	AND suic.year=ind.year
	AND suic.sex=ind.sex

SELECT *
FROM SuicideANDIndicators