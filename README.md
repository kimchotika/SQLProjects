# 📊 COVID-19 Data Analysis with SQL

This project explores global COVID-19 trends using SQL to analyze and visualize key metrics such as infection rates, death rates, and vaccination progress. The dataset includes COVID-19 death and vaccination records, and the analysis is performed using SQL Server.

---

## 📁 Dataset

The project uses two main tables:

- `CovidDeaths`: Contains data about confirmed cases, deaths, and population.
- `CovidVaccination`: Includes data on vaccination counts by country and date.

---

## 🧰 Tools & Technologies

- **SQL Server** (T-SQL)
- **Windows/Mac** (SQL execution environment)
- **Data Source**: Our World in Data COVID-19 dataset

---

## 🔍 Key Analyses

### 1. **Total Cases vs Total Deaths**
Analyzes the death rate over time for selected countries, including the U.S.

```sql
SELECT location, date, population, total_cases, total_deaths, 
       (total_deaths/total_cases)*100 AS deaths_percentage
FROM CovidDeaths 
WHERE location LIKE '%states%' AND continent IS NOT NULL
```

---

### 2. **Total Cases vs Population**
Calculates the percentage of the population infected over time.

```sql
SELECT location, date, total_cases, population, 
       (total_cases/population)*100 AS infection_percentage
FROM CovidDeaths 
WHERE location LIKE '%states%'
```

---

### 3. **Countries with Highest Infection Rate**
Shows which countries had the highest proportion of their population infected.

```sql
SELECT location, population, MAX(total_cases) AS HighestInfection, 
       MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC
```

---

### 4. **Highest Death Count by Country and Continent**
Identifies the locations with the highest total deaths.

```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM CovidDeaths 
WHERE continent IS NOT NULL 
GROUP BY location 
ORDER BY TotalDeathsCount DESC
```

---

### 5. **Rolling Average of Deaths**
Calculates a 7-day moving average of new deaths globally.

```sql
SELECT 
  AVG(CAST(new_deaths AS INT)) OVER(ORDER BY date ROWS BETWEEN CURRENT ROW AND 7 FOLLOWING) AS moving_average
FROM CovidDeaths 
WHERE continent IS NOT NULL AND new_deaths IS NOT NULL
```

---

### 6. **Population vs Vaccination Progress**
Analyzes vaccination rates per country using joins and window functions.

```sql
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS ROLLINGPPLVAC
FROM CovidDeaths dea
JOIN CovidVaccination vac 
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
```

---

## 🧮 Advanced SQL Techniques Used

- **CTEs (Common Table Expressions)**
- **Temporary Tables**
- **Window Functions** (`SUM() OVER`, `AVG() OVER`)
- **Views** (for dashboarding or visualization prep)
- **Joins** between deaths and vaccination data

---

## 📈 View Creation for Visualization

To support BI tools like Tableau or Power BI, a view was created:

```sql
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS ROLLINGPPLVAC
FROM CovidDeaths dea
JOIN CovidVaccination vac ON dea.location = vac.location AND dea.date = vac.date
```

---

## 📌 How to Use

1. Load the `CovidDeaths` and `CovidVaccination` datasets into your SQL environment.
2. Run the queries step-by-step to explore different insights.
3. Use the view `PercentPopulationVaccinated` as a data source in BI tools for creating dashboards.

---

## 📚 Learning Outcomes

- Practice with real-world public health data
- Proficiency in SQL joins, window functions, and CTEs
- Creating data pipelines for dashboards
