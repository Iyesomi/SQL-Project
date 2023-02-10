
Select *
From [Portfolio Project]..CovidDeath
where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccination
--order by 3,4

--Select the data needed for data exploration

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeath
order by 1,2 

--Compare total cases vs total deaths
--Create a new column called Death ratio

ALTER TABLE dbo.CovidDeath
ADD death_ratio AS (total_deaths/total_cases)*100

--I created the column twice so i used the drop column syntax to delete the extra column.

ALTER TABLE dbo.CovidDeath
DROP COLUMN Death_percentage

Select location, date, total_cases,total_deaths, death_ratio
From [Portfolio Project]..CovidDeath
order by 1,2 

--Total cases vs Population (percentage of the total population that contracted covid)
--Create a new column called population ratio

ALTER TABLE dbo.CovidDeath
ADD population_ratio AS (total_cases/population)*100

--View the population column for Nigeria

Select location, date, population, total_cases, population_ratio
From [Portfolio Project]..CovidDeath
Where location like '%Nigeria%'
order by population_ratio desc

--On the 30th of April 2021, Nigeria recorded the highest percentage of the total population that contracted covid.

--Looking at countries with highest infection rates compared to population
--Order by the percentage of population infected to get the country with the highest percentage of its population infected

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(population_ratio) as PercentPopulationInfected
From [Portfolio Project]..CovidDeath
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Andorra despite having a small population had the highest percenatge of its population infected.


--Countries with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeath
where continent is not null
Group by location
order by TotalDeathCount desc

--The United States have the highest death count. 



Select *
From [Portfolio Project]..CovidVaccination

--Join both tables 

Select *
From [Portfolio Project]..CovidDeath dea
Join [Portfolio Project]..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date

 --Total amount of people that were vaccinated per day
 Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount
 --, (RollingCount/population) *100
 From [Portfolio Project]..CovidDeath dea
Join [Portfolio Project]..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null      
 order by 2,3

 --Using CTE
With Popuvac (continent, location, date, population, new_vaccinations, RollingCount)
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingCount
 --, (RollingCount/population) *100
 From [Portfolio Project]..CovidDeath dea
Join [Portfolio Project]..CovidVaccination vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null      
 )
 Select *, (RollingCount/population)*100
 From Popuvac