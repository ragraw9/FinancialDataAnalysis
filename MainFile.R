library(fastDummies)
library(dplyr)
library(MASS)
library(rvest)
library(XML)
library(tidyverse)
library(readxl)
library(dplyr)
library(polite)
library(haven)
rm(list=ls())

#1.
AR<-data.frame(read_sas("C:/Users/Rohan/Desktop/UIC/Fall 23/IDS 462/Week 15/Final Project/Data/annualreports(2).sas7bdat"))
colnames(AR)

#2.
AR[]<-lapply(AR,function(x) {attributes(x)<-NULL;x})

#3.
# Convert FiscalYearDate from character to date
AR$FiscalYearDate <- as.Date(AR$FiscalYearDate, format = "%Y-%m-%d")
AR$FiscalYearDate

#4. 
# Extract the year from the FiscalYearDate
AR$FiscalYear <- format(AR$FiscalYearDate, "%Y")
AR$FiscalYear

#5.

AR <- AR %>% filter(as.numeric(FiscalYear) <= 2013)
AR$FiscalYear

#6.

main <- AR %>% 
  filter(Sector == "Consumer Servic", Industry == "Restaurants")
main

#7. 
main <- main %>% distinct(Name, FiscalYear, .keep_all = TRUE)
main$Name

#8.
company_counts <- table(main$Name)
company_counts

# Sort and get the top four companies
top_companies_names <- names(sort(company_counts, decreasing = TRUE)[1:4])
top_companies_names

# Create a new data frame with top companies and their counts
top_companies_data <- data.frame(
  Name = top_companies_names,
  Count = company_counts[top_companies_names]
)

top_companies_cleaned <- top_companies_data[, c("Name", "Count.Freq")]
top_companies_cleaned

#9. 
top_company_names <- top_companies_data$Name
top_companies_main <- main %>% filter(Name %in% top_company_names)
top_companies_main$Name

#10. 
top_companies_main$CleanedName <- str_remove_all(top_companies_main$Name, "[ .(),#-;]")
top_companies_main$CleanedName 

#11. 
library(fastDummies)

top_companies_main <- dummy_cols(top_companies_main, select_columns = "CleanedName", remove_selected_columns = TRUE)
top_companies_main

#Remove the "CleanedName_" prefix from the dummy column names
names(top_companies_main) <- gsub("CleanedName_", "", names(top_companies_main))
names(top_companies_main)

#12. 
top_companies_main$PFCI<- as.numeric(top_companies_main$PriceFreeCashflowToIndustry)
top_companies_main$PFCI
top_companies_main$Symbol
anova_result<- aov(PFCI ~ Symbol, data= top_companies_main)
summary(anova_result)

#14.
options<-data.frame(read_sas("C:/Users/Rohan/Desktop/UIC/Fall 23/IDS 462/Week 15/Final Project/Data/optionsfile(1).sas7bdat"))
options[]<-lapply(options,function(x) {attributes(x)<-NULL;x})
options$expdate<-as.Date(options$expdate, origin='1970-01-01')
options$capturedate<-as.Date(options$capturedate, origin='1970-01-01')

#15.
start_date<-as.Date('2014-05-01')
end_date<-as.Date('2016-01-31')

options<- subset(options, expdate> start_date & expdate< end_date)
options

#16.
unique_symbols <- unique(main$Symbol)
AR_filtered_symbols <- AR %>% filter(Symbol %in% unique_symbols)
AR_filtered_symbols$Name

#17. 
matched_data <- merge(AR_filtered_symbols, options, by.x = "Symbol", by.y = "underlying", all.x = TRUE)
matched_data

#18. 
symbols_of_interest <- c("ARKR", "BH", "BOBE", "EAT")
filtered_data <- matched_data[matched_data$Symbol %in% symbols_of_interest, ]
option_counts <- table(filtered_data$Symbol)
option_counts

#19.
average_strike_prices <- filtered_data %>%
  group_by(Symbol, type) %>%
  summarise(AverageStrikePrice = mean(strike, na.rm = TRUE))
average_strike_prices

#19.
divd<-data.frame(read_sas("C:/Users/Rohan/Desktop/UIC/Fall 23/IDS 462/Week 15/Final Project/Data/divfile(1).sas7bdat"))
divd[]<-lapply(divd,function(x) {attributes(x)<-NULL;x})
divd
divd$date<-as.Date(divd$date)

divd_filtered <- subset(divd, date >= as.Date("2011-01-01"))


#20-23.
top_company_symbols <- c("ARKR", "BH", "BOBE", "EAT")
matched_dividends <- divd_filtered[divd_filtered$tic %in% top_company_symbols, ]
matched_dividends
total_dividends <- aggregate(DivAmount ~ tic, data = matched_dividends, sum)
print(total_dividends)

#24.
price<-data.frame(read_sas("C:/Users/Rohan/Desktop/UIC/Fall 23/IDS 462/Week 15/Final Project/Data/pricesrevised(1).sas7bdat"))
price

#25
price$date <- as.Date(price$date)
price$year <- format(price$date, "%Y")
price$year
price$year<- as.numeric(price$year)

#26
price_filtered <- subset(price, year >= 2011)
colnames(price_filtered)

#27
top_company_symbols_df <- data.frame(tic = top_company_symbols)
matched_prices <- merge(price_filtered, top_company_symbols_df, by = "tic")
tail(matched_prices$tic)

#28
matched_prices$date <- as.Date(matched_prices$date)

prices_2011 <- subset(matched_prices, format(date, "%Y") == "2011")

first_day_prices <- prices_2011 %>% 
  group_by(tic) %>% 
  filter(date == min(date)) %>% 
  dplyr::select(tic, date, open)
print(first_day_prices)

#29
merged_data <- merge(first_day_prices, matched_dividends, by = "tic")
merged_data

#30
merged_data$DividendYield <- with(merged_data, ifelse(is.na(DivAmount) | DivAmount == 0, 0, (DivAmount / open) * 100))
print(merged_data)

#31. 
splitsfile<-data.frame(read_sas("C:/Users/Rohan/Desktop/UIC/Fall 23/IDS 462/Week 15/Final Project/Data/splits(1).sas7bdat"))
splitsfile

#32
splitsfile[]<-lapply(splitsfile,function(x) {attributes(x)<-NULL;x})
splitsfile

#33
splitsfile$Date<- as.Date(splitsfile$Date)
splitsfile$Date

#34
splitsfile$Date <- as.Date(splitsfile$Date)

# Filter records for 1992 and after
splitsfile_filtered <- splitsfile %>% 
  filter(Date >= as.Date("1992-01-01"))
splitsfile_filtered

#35
top_company_symbols_df <- data.frame(Symbol = top_company_symbols)


merged_data_with_splits <- merge(merged_data, splitsfile_filtered, by = "tic", all.x = TRUE)

tail(merged_data_with_splits)

#36. 
split_summary <- merged_data_with_splits %>%
  group_by(tic) %>%
  summarise(MinSplit = min(Split, na.rm = TRUE),
            MaxSplit = max(Split, na.rm = TRUE))

print(split_summary)

#37. 

options_wide <- average_strike_prices %>%
  spread(type, AverageStrikePrice)
options_wide
combined_data <- options_wide %>%
  left_join(total_dividends, by = c("Symbol" = "tic")) %>%
  left_join(split_summary, by = c("Symbol" = "tic"))

print(combined_data)

'
#Piotroski Method:

AR$FiscalYear <- year(AR$FiscalYearDate)

# Filter for Fiscal Year 2008
AR_2008 <- filter(AR, FiscalYear == 2008)

# Select relevant companies
top_company_symbols <- c("ARKR", "BH", "BOBE", "EAT")
AR_2008_filtered <- AR_2008 %>% filter(Symbol %in% top_company_symbols)

# Calculate Piotroski F-Score components
AR_2008_filtered <- AR_2008_filtered %>%
  mutate(
    PositiveNetIncome = ifelse(ISNetIncomeTotalOperations > 0, 1, 0),
    PositiveOpCashFlow = ifelse(CFONetCashContOps > 0, 1, 0),
    ROA = ISNetIncomeTotalOperations / BSTotalAssets,
    ROALastYear = lag(ROA),
    ROAIncreased = ifelse(is.na(ROALastYear) | ROA > ROALastYear, 1, 0),
    QualityEarnings = ifelse(CFONetCashContOps > ISNetIncomeTotalOperations, 1, 0),
    LongTermDebt = BSLTDebt / BSTotalAssets,
    LongTermDebtLastYear = lag(LongTermDebt),
    DecreasedLeverage = ifelse(is.na(LongTermDebtLastYear) | LongTermDebt < LongTermDebtLastYear, 1, 0),
    CurrentRatio = BSTotalCurAssets / BSTotalCurrentLiabilities,
    CurrentRatioLastYear = lag(CurrentRatio),
    IncreasedLiquidity = ifelse(is.na(CurrentRatioLastYear) | CurrentRatio > CurrentRatioLastYear, 1, 0),
    SharesLastYear = lag(BSSharesOutCommon),
    NoNewShares = ifelse(is.na(SharesLastYear) | BSSharesOutCommon <= SharesLastYear, 1, 0),
    GrossMargin = ISGrossMargin / ISTotRev,
    GrossMarginLastYear = lag(GrossMargin),
    IncreasedMargin = ifelse(is.na(GrossMarginLastYear) | GrossMargin > GrossMarginLastYear, 1, 0),
    AssetTurnover = ISTotRev / BSTotalAssets,
    AssetTurnoverLastYear = lag(AssetTurnover),
    IncreasedTurnover = ifelse(is.na(AssetTurnoverLastYear) | AssetTurnover > AssetTurnoverLastYear, 1, 0)
  ) %>%
  mutate(
    FScore = PositiveNetIncome + PositiveOpCashFlow + ROAIncreased + QualityEarnings + DecreasedLeverage + IncreasedLiquidity + NoNewShares + IncreasedMargin + IncreasedTurnover
  )

# Final Output
final_output <- AR_2008_filtered %>%
  dplyr::select(Symbol, FScore)
print(final_output)
'