Select *
From PortfolioProject.dbo.[Covid Death]
order by 3 , 4


-- Select Spacific Data From Database
Select Location , date , total_cases , new_cases ,total_deaths, population
From PortfolioProject.dbo.[Covid Death]
order by 1 , 2


-- Look for the total case vs total death
Select Location , date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPersantage
From PortfolioProject.dbo.[Covid Death]
order by 1 , 2


-- Look for the total case vs total death
-- Code Fix Data at total_cases & total_deaths that not numbers type by convert it by CAST Function
-- Filterd location by Egypt 
SELECT Location, date, total_cases, total_deaths, 
       (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.[Covid Death]
where location = 'Egypt'
ORDER BY 1, 2

-- Look For Total Case Vs Population
Select Location , date , population, total_cases ,
       (CAST(total_cases AS float) / CAST(population AS float)) * 100 as CasePercentage
FROM PortfolioProject.dbo.[Covid Death]
where location = 'Egypt'
ORDER BY 1, 2

-- Looking at Countries With Highest Infection Rate Compared to Population
Select Location , population,
      Max(CAST(total_cases AS float)) as HighestInfectionCount ,
	  Max((CAST(total_cases AS float) / CAST(population AS float))) * 100 as CasePercentage
FROM PortfolioProject.dbo.[Covid Death]
Group by Location , population
ORDER BY CasePercentage desc

-- Showing Countries With Highest Death Count Per Population
Select Location ,
	  Max(cast(total_deaths as float)) as HighestDeathCount 
FROM PortfolioProject.dbo.[Covid Death]
Where continent is not null -- to remove the Doublicate for Continent in Continent
Group by Location
ORDER BY HighestDeathCount desc

-- Group by continent & Population
Select location , population ,
	  Max(cast(total_deaths as float)) as HighestDeathCount
FROM PortfolioProject.dbo.[Covid Death]
Where continent is null -- to remove the Doublicate for Continent in location column
Group by location , population
HAVING location NOT IN ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
-- using having to hide not neccesry rows for 'High income'& 'Upper middle income'& 'Lower middle income'& 'Low income'
ORDER BY HighestDeathCount desc

-- Global Numbers 
-- look to the data in general without any specified any country (General to the world )
-- will group by dates
-- issue here total case still not sum !!!! video at 46.36 min
-- fixed the cumulative by use sum +over  (SUM(cast (new_cases as float)) OVER (ORDER BY date) AS Cumulative_Cases,)
-- issue shown doublicated row of dates but Cumulative Work Correctectly
Select date , 
	SUM(cast (new_cases as float)) OVER (ORDER BY date) AS Cumulative_Cases,-- fixed the cumulative by use sum +over
	SUM(cast (new_deaths as float)) OVER (ORDER BY date) AS Cumulative_Deaths-- fixed the cumulative by use sum +over
From PortfolioProject.dbo.[Covid Death]
where continent is not null
group by date ,new_cases,new_deaths
order by  date

-- Global Numbers 
-- This Table to show Cumlative Case , death & Persantage daily
Select date , 
	SUM(cast (new_cases as float)) OVER (ORDER BY date) AS Cumulative_Cases,-- fixed the cumulative by use sum +over
	SUM(cast (new_deaths as float)) OVER (ORDER BY date) AS Cumulative_Deaths, -- fixed the cumulative by use sum +over
	CASE WHEN SUM(CAST(new_cases AS float)) OVER (ORDER BY date) <> 0 -- Fix Dividening Over Zero
		 THEN SUM(CAST(new_deaths AS float)) OVER (ORDER BY date)/SUM(CAST(new_cases AS float)) OVER (ORDER BY date)*100
		 ELSE NULL
	END AS Case_Death_Rate
From PortfolioProject.dbo.[Covid Death]
where continent is not null
group by date ,new_cases,new_deaths
order by  date

-- Global Numbers 
-- This Table to show Total Case , death & Persantage Up to Database Date
Select  SUM(cast (new_cases as float)) AS Cumulative_Cases,
		SUM(cast (new_deaths as float)) AS Cumulative_Deaths, 
	SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))*100 AS Case_Death_Rate
From PortfolioProject.dbo.[Covid Death]
where continent is not null
-----------------------------------------------------------------------------------
--Join Vaccination & Death Tables Togther 
Select *
from PortfolioProject.dbo.[Covid Death] Dea  -- Dea is Short Name to easy way to use when call the table
join PortfolioProject.dbo.[Covid vaccinations] Vac -- Vac is Short Name to easy way to use when call the table
on Dea.location = Vac.location
and Dea.date = Vac.date
order by Dea.date


--Join Vaccination & Death Tables Togther 
--Look For Total Population vs Vaccinated
Select Dea.continent, Dea.location,Dea.date,Dea.population,Vac.new_vaccinations ,
		SUM(cast (Vac.new_vaccinations as float)) OVER (partition by Dea.location ORDER BY Dea.location ,Dea.date) AS Cumulative_vaccinations 
		-- Cumulative Vaccination Equation
		-- Partition used for cut the cum when location change
from PortfolioProject.dbo.[Covid Death] Dea  -- Dea is Short Name to easy way to use when call the table
join PortfolioProject.dbo.[Covid vaccinations] Vac -- Vac is Short Name to easy way to use when call the table
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3
-----------------------------------------------------------------------------------
-- Create Vaccination/Population %
-- Must Use CTE عند وجودعمود جديد موجود وتريد عمل معادلة معتمدة عليه
with popvsvac(continent,location,date,population,new_vaccinations,Cumulative_vaccinations)
as
(
Select Dea.continent, Dea.location,Dea.date,Dea.population,Vac.new_vaccinations ,
		SUM(cast (Vac.new_vaccinations as float)) OVER (partition by Dea.location ORDER BY Dea.location ,Dea.date) AS Cumulative_vaccinations 
		-- Cumulative Vaccination Equation
		-- Partition used for cut the cum when location change
from PortfolioProject.dbo.[Covid Death] Dea  -- Dea is Short Name to easy way to use when call the table
join PortfolioProject.dbo.[Covid vaccinations] Vac -- Vac is Short Name to easy way to use when call the table
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
)
select *,cast((Cumulative_vaccinations/population)*100  as decimal (10,2)) as Vaccination_Persantage -- use decimal to show only 2 numbers after decimal
from popvsvac
order by 2,3










