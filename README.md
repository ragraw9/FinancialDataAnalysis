# Financial Data Analysis

## Overview
This project showcases advanced data manipulation and analysis in R, focusing on financial datasets. It includes importing, cleaning, transforming, and analyzing financial data from various sectors.

## Dependencies
- R packages required: `fastDummies`, `dplyr`, `MASS`, `rvest`, `XML`, `tidyverse`, `readxl`, `polite`, `haven`

## File Description
- `Main.R`: Main R script for data processing and analysis.

## Data Source
Data is sourced from SAS datasets. File paths within the script will need to be adjusted to your local dataset locations.

## Features
- **Data Import and Cleaning:** Importing and cleaning financial data from SAS files.
- **Date Transformation:** Converting and extracting date components for analysis.
- **Data Filtering:** Sector and timeframe-specific data filtering.
- **Statistical Analysis:** Statistical comparison of financial metrics.
- **Data Aggregation:** Summarizing dividend and stock price data.

## Usage
1. Install all the required R packages.
2. Update the SAS file paths to your local dataset locations.
3. Execute the script in R or RStudio.

## Detailed Functionality
- **Data Importing and Cleaning (Steps 1-2):** Import and clean data using `read_sas` and `lapply`.
- **Date Conversion and Year Extraction (Steps 3-4):** FiscalYearDate conversion from character to date and year extraction.
- **Sector-Specific Data Filtering (Step 6):** Filter for 'Consumer Service' sector and 'Restaurants' industry.
- **Data Deduplication (Step 7):** Remove duplicates, focusing on unique company names.
- **Options Data Processing (Step 14):** Process options data, including date conversions.
- **Symbol-Based Filtering and Merging (Steps 16-17):** Filter annual reports by symbols and merge with options data.
- **Financial Analysis (Step 19):** Aggregate strike prices, perform dividend analysis.
- **Stock Price Analysis (Steps 25-29):** Analyze stock prices, focusing on opening prices.
- **Dividend Yield Calculation (Step 30):** Calculate dividend yield based on open price.
- **Advanced Financial Scoring (Piotroski Method):** Financial health assessment using Piotroski F-Score.

## Author
Rohan Agrawal
