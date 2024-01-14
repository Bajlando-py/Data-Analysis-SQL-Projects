# SQL-Projects

## Project 1 SQL Data Exploration

#### Technologies used
+ SSMS
+ SQL
+ XLSX and CVS files

### Overview
For this project I downloaded this [dataset](https://ourworldindata.org/covid-deaths) from *ourworldindata.org*. Dataset was separated into two logical XLSX documents. XLSX documents were uploaded into SSMS and two tables were created.  
There are about 11 queries that range from simple ones with select, where, order by, group by and agregation functions up to partition by, case statement, joins, cte, temporary table and view. Every query has short and clear explanation as a comment above it.

In this project I calculated real data with SQL queries like percentage of infected people per whole population by country, percentage of deaths per infected population and per whole country population and much more.

For all files please go to the branch [SQL_Data_Exploration](https://github.com/Bajlando-py/Data-Analysis-SQL-Projects/tree/SQL_Data_Exploration) and open the folder **Project-1 SQL_Data_Exploration** or you can go straight to SQL file [here.](https://github.com/Bajlando-py/Data-Analysis-SQL-Projects/blob/SQL_Data_Exploration/Project-1%20SQL_Data_Exploration/project1SQLDataExploration.sql)

---

## Project 2 SQL Data Cleaning

#### Technologies used
+ SSMS
+ SQL
+ XLSX

In this project I didn't do any data cleaning in excel. Instead I used SSMS and SQL commands like update, set, convert, alter table/column, join, substring, parsename for data cleaning and data type converting.  
For example I did self JOIN where I updated parcelID's addresses from NULL values to correct addresses where the same parcelID in different row had a valid address or I splitted column with full addresses into three new columns street, city and state and more.

For all files please go to the branch [SQL_Data_Cleaning](https://github.com/Bajlando-py/Data-Analysis-SQL-Projects/tree/SQL_Data_Cleaning) and open the folder **Project-2-SQL_Data_Cleaning** or you can go straight to SQL file [here.](https://github.com/Bajlando-py/Data-Analysis-SQL-Projects/blob/SQL_Data_Cleaning/Project-2-SQL_Data_Cleaning/project2SQLDataCleaning.sql)
