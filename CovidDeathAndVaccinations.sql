--Total cases vs Total Deaths by country
--Shows likelihood of dying if an individual caught Covid in their country
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (CAST(total_deaths AS float) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL 
    AND location LIKE '%States%'
ORDER BY 
    location, 
    date;


--Countries with highest infection rate relative to population
SELECT 
    location, 
    population, 
    MAX(total_cases) AS HighestInfectionCount, 
    (MAX(CAST(total_cases AS float)) / population) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location, 
    population
ORDER BY 
    PercentPopulationInfected DESC;


--Countries with Highest Death Count per population
SELECT 
    location, 
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;

order by TotalDeathCount desc

--Continents with Highest Death Count per population
SELECT 
    location, 
    MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NULL 
    AND location NOT LIKE '%income%'
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;


--Global numbers
--Number of people infected globally
SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(CAST(new_deaths AS int)) AS total_deaths, 
    SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    total_cases, 
    total_deaths;


-- Total population against vaccinations
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
ORDER BY 
	2, 3;


--Population against vaccination cases
With PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Population_vaccinated_percentage
FROM PopVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
ORDER BY 
	2, 3;


--Population against vaccination cases
With PopVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Population_vaccinated_percentage
FROM #PercentPopulationVaccinated


--View to store data for later visualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN 
	PortfolioProject..CovidVaccinations vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
