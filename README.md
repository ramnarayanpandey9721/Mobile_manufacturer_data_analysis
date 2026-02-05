# Mobile_manufacturer_data_analysis

This project contains SQL Server–compatible solutions for the Advanced SQL Case Study based on the Cellphones Information database.
The case study analyzes cellphone sales transactions using a star schema consisting of dimension and fact tables.

Database Structure

Dim_Manufacturer

Dim_Model

Dim_Customer

Dim_Location

Fact_Transactions

Each row in Fact_Transactions represents a single sales transaction.

Scope

The queries address:

Sales analysis by state, zip code, and year

Manufacturer and model performance

Customer spending behavior

Top-N and year-over-year analysis using window functions

Technical Details

Platform: Microsoft SQL Server

Language: T-SQL

Techniques: JOINs, CTEs, aggregates, window functions

Notes

All queries follow the provided schema

Each query returns a single result set

No permanent database modifications were made

Answers are placed strictly between BEGIN and END tags
