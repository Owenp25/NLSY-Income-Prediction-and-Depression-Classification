library(dplyr)
library(tidyverse)
library(caret)
library(e1071)
library(performanceEstimation)
library(ggpubr)
library(FactoMineR)
library(factoextra)
# Set working directory

new_data <- read.table('NLSY_PROJ_DATA.dat', sep=' ')
names(new_data) <- c('R0000100',
'U3437900',
'U3438000',
'U3444000',
'U3444100',
'U3444200',
'U3444500',
'U3451400',
'U3451600',
'U3451900',
'U3452000',
'U3453600',
'U3453800',
'U3455100',
'U4112100',
'U4282100',
'U4282300',
'U4285700',
'U4368000',
'U4368100',
'U4368200',
'U4368400',
'U4368500',
'U4368600',
'U4368700',
'U4368900',
'U4370902')


# Handle missing values

# bio children
new_data$U3451900[new_data$U3451900 == -4] = 0 
# region
new_data$U3438000[new_data$U3438000 == -4] = NA 
# MSA
new_data$U3451600[new_data$U3451600 == -4] = NA 
# non-res bio children
new_data$U3452000[new_data$U3452000 == -4] = 0
# urban/rural
new_data$U3453600[new_data$U3453600 == -4] = NA
# perc chance wrk 20 hrs 1 yr
new_data$U4112100[new_data$U4112100 == -4] = 0 
# any income last year 
new_data$U4282100[new_data$U4282100 == -4] = 0 
# total income
new_data$U4282300[new_data$U4282300 == -4] = NA
# income from gov programs
new_data$U4285700[new_data$U4285700 == -4] = 0
# health
new_data$U4368000[new_data$U4368000 == -4] = NA
# weight
new_data$U4368100[new_data$U4368100 == -4] = NA
# chronic pain/illness
new_data$U4368200[new_data$U4368200 == -4] = 0
# limited type work
new_data$U4368400[new_data$U4368400 == -4] = 0
# limited amt work
new_data$U4368500[new_data$U4368500 == -4] = 0
# injuries
new_data$U4368600[new_data$U4368600 == -4] = 0

# emo health prob
new_data$U4368700[new_data$U4368700 == -4] = 0
# any health care
new_data$U4368900[new_data$U4368900 == -4] = 0
# depressed
new_data$U4370902[new_data$U4370902 == -4] = 0



new_data[new_data == -1] = NA  # Refused
new_data[new_data == -2] = NA  # Dont know
new_data[new_data == -3] = NA  # Invalid missing
new_data[new_data == -5] = NA  # Non-interview



# If there are values not categorized they will be represented as NA

vallabels = function(data) {
  data$U3437900 <- factor(data$U3437900,
levels=c(33.0,34.0,35.0,36.0,37.0,38.0,39.0,40.0),
labels=c("33",
"34",
"35",
"36",
"37",
"38",
"39",
"40"))
  data$U3438000 <- factor(data$U3438000,
levels=c(1.0,2.0,3.0,4.0),
labels=c("Northeast (CT, ME, MA, NH, NJ, NY, PA, RI, VT)",
"North Central (IL, IN, IA, KS, MI, MN, MO, NE, OH, ND, SD, WI)",
"South (AL, AR, DE, DC, FL, GA, KY, LA, MD, MS, NC, OK, SC, TN , TX, VA, WV)",
"West (AK, AZ, CA, CO, HI, ID, MT, NV, NM, OR, UT, WA, WY)"))
  data$U3444500 <- factor(data$U3444500,
levels=c(0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0),
labels=c("None",
"GED",
"High school diploma (Regular 12 year program)",
"Associate/Junior college (AA)",
"Bachelor's degree (BA, BS)",
"Master's degree (MA, MS)",
"PhD",
"Professional degree (DDS, JD, MD)"))
  data$U3451400 <- factor(data$U3451400,
levels=c(1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0),
labels=c("Never married, cohabiting",
"Never married, not cohabiting",
"Married, spouse present",
"Married, spouse absent",
"Separated, cohabiting",
"Separated, not cohabiting",
"Divorced, cohabiting",
"Divorced, not cohabiting",
"Widowed, cohabiting",
"Widowed, not cohabiting"))
  data$U3451600 <- factor(data$U3451600,
levels=c(1.0,2.0,3.0,4.0,5.0),
labels=c("Not in CBSA",
"In CBSA, not in central city",
"In CBSA, in central city",
"In CBSA, not known",
"Not in country"))
  data$U3453600 <- factor(data$U3453600,
levels=c(0.0,1.0,2.0),
labels=c("Rural",
"Urban",
"Unknown"))
  data$U3455100 <- factor(data$U3455100,
levels=c(0.0,1.0,2.0),
labels=c("Not currently working at a job",
"Current working at a job",
"Military service (but no job) reported"))
  data$U4282100 <- factor(data$U4282100,
levels=c(0.0,1.0),
labels=c("NO",
"YES"))
  data$U4285700 <- factor(data$U4285700,
levels=c(0.0,1.0),
labels=c("NO",
"YES"))
  data$U4368000 <- factor(data$U4368000,
levels=c(1.0,2.0,3.0,4.0,5.0),
labels=c("Excellent",
"Very good",
"Good",
"Fair",
"Poor"))
  data$U4368200 <- factor(data$U4368200,
levels=c(0.0,1.0),
labels=c("NO",
"YES"))
  data$U4368400 <- factor(data$U4368400,
levels=c(0.0,1.0),
labels=c("NO",
"YES"))
  data$U4368500 <- factor(data$U4368500,
levels=c(0.0,1.0),
labels=c("NO",
"YES"))
  data$U4368600 <- factor(data$U4368600,
levels=c(1.0,2.0,3.0,4.0,5.0),
labels=c("NONE",
"1 TIME",
"2 TIMES",
"3 TIMES",
"4 OR MORE TIMES"))
  data$U4368700 <- factor(data$U4368700,
levels=c(1.0,2.0,3.0,4.0,5.0),
labels=c("NONE",
"1 TIME",
"2 TIMES",
"3 TIMES",
"4 OR MORE TIMES"))
  data$U4368900 <- factor(data$U4368900,
levels=c(0.0,1.0),
labels=c("NO",
"YES"))
  data$U4370902 <- factor(data$U4370902,
levels=c(0.0,1.0,2.0,3.0),
labels=c("Rarely/None of the time/1 Day",
"Some/A little of the time/1-2 Days",
"Occasionally/Moderate amount of the time/3-4 Days",
"Most/All of the time/ 5-7 Days"))
return(data)
}


# If there are values not categorized they will be represented as NA

vallabels_continuous = function(data) {
data$R0000100[1.0 <= data$R0000100 & data$R0000100 <= 999.0] <- 1.0
data$R0000100[1000.0 <= data$R0000100 & data$R0000100 <= 1999.0] <- 1000.0
data$R0000100[2000.0 <= data$R0000100 & data$R0000100 <= 2999.0] <- 2000.0
data$R0000100[3000.0 <= data$R0000100 & data$R0000100 <= 3999.0] <- 3000.0
data$R0000100[4000.0 <= data$R0000100 & data$R0000100 <= 4999.0] <- 4000.0
data$R0000100[5000.0 <= data$R0000100 & data$R0000100 <= 5999.0] <- 5000.0
data$R0000100[6000.0 <= data$R0000100 & data$R0000100 <= 6999.0] <- 6000.0
data$R0000100[7000.0 <= data$R0000100 & data$R0000100 <= 7999.0] <- 7000.0
data$R0000100[8000.0 <= data$R0000100 & data$R0000100 <= 8999.0] <- 8000.0
data$R0000100[9000.0 <= data$R0000100 & data$R0000100 <= 9999.0] <- 9000.0
data$R0000100 <- factor(data$R0000100,
levels=c(0.0,1.0,1000.0,2000.0,3000.0,4000.0,5000.0,6000.0,7000.0,8000.0,9000.0),
labels=c("0",
"1 TO 999",
"1000 TO 1999",
"2000 TO 2999",
"3000 TO 3999",
"4000 TO 4999",
"5000 TO 5999",
"6000 TO 6999",
"7000 TO 7999",
"8000 TO 8999",
"9000 TO 9999"))
data$U3444000[-999999.0 <= data$U3444000 & data$U3444000 <= -3000.0] <- -999999.0
data$U3444000[-2999.0 <= data$U3444000 & data$U3444000 <= -2000.0] <- -2999.0
data$U3444000[-1999.0 <= data$U3444000 & data$U3444000 <= -1000.0] <- -1999.0
data$U3444000[-999.0 <= data$U3444000 & data$U3444000 <= -1.0] <- -999.0
data$U3444000[1.0 <= data$U3444000 & data$U3444000 <= 1000.0] <- 1.0
data$U3444000[1001.0 <= data$U3444000 & data$U3444000 <= 2000.0] <- 1001.0
data$U3444000[2001.0 <= data$U3444000 & data$U3444000 <= 3000.0] <- 2001.0
data$U3444000[3001.0 <= data$U3444000 & data$U3444000 <= 5000.0] <- 3001.0
data$U3444000[5001.0 <= data$U3444000 & data$U3444000 <= 10000.0] <- 5001.0
data$U3444000[10001.0 <= data$U3444000 & data$U3444000 <= 20000.0] <- 10001.0
data$U3444000[20001.0 <= data$U3444000 & data$U3444000 <= 30000.0] <- 20001.0
data$U3444000[30001.0 <= data$U3444000 & data$U3444000 <= 40000.0] <- 30001.0
data$U3444000[40001.0 <= data$U3444000 & data$U3444000 <= 50000.0] <- 40001.0
data$U3444000[50001.0 <= data$U3444000 & data$U3444000 <= 65000.0] <- 50001.0
data$U3444000[65001.0 <= data$U3444000 & data$U3444000 <= 80000.0] <- 65001.0
data$U3444000[80001.0 <= data$U3444000 & data$U3444000 <= 100000.0] <- 80001.0
data$U3444000[100001.0 <= data$U3444000 & data$U3444000 <= 150000.0] <- 100001.0
data$U3444000[150001.0 <= data$U3444000 & data$U3444000 <= 200000.0] <- 150001.0
data$U3444000[200001.0 <= data$U3444000 & data$U3444000 <= 999999.0] <- 200001.0
data$U3444000 <- factor(data$U3444000,
levels=c(-999999.0,-2999.0,-1999.0,-999.0,0.0,1.0,1001.0,2001.0,3001.0,5001.0,10001.0,20001.0,30001.0,40001.0,50001.0,65001.0,80001.0,100001.0,150001.0,200001.0),
labels=c("-999999 TO -3000: < -2999",
"-2999 TO -2000",
"-1999 TO -1000",
"-999 TO -1",
"0",
"1 TO 1000",
"1001 TO 2000",
"2001 TO 3000",
"3001 TO 5000",
"5001 TO 10000",
"10001 TO 20000",
"20001 TO 30000",
"30001 TO 40000",
"40001 TO 50000",
"50001 TO 65000",
"65001 TO 80000",
"80001 TO 100000",
"100001 TO 150000",
"150001 TO 200000",
"200001 TO 999999: 200001+"))
data$U3444100[1.0 <= data$U3444100 & data$U3444100 <= 99.0] <- 1.0
data$U3444100[100.0 <= data$U3444100 & data$U3444100 <= 199.0] <- 100.0
data$U3444100[200.0 <= data$U3444100 & data$U3444100 <= 299.0] <- 200.0
data$U3444100[300.0 <= data$U3444100 & data$U3444100 <= 399.0] <- 300.0
data$U3444100[400.0 <= data$U3444100 & data$U3444100 <= 499.0] <- 400.0
data$U3444100[500.0 <= data$U3444100 & data$U3444100 <= 599.0] <- 500.0
data$U3444100[600.0 <= data$U3444100 & data$U3444100 <= 699.0] <- 600.0
data$U3444100[700.0 <= data$U3444100 & data$U3444100 <= 799.0] <- 700.0
data$U3444100[800.0 <= data$U3444100 & data$U3444100 <= 899.0] <- 800.0
data$U3444100[900.0 <= data$U3444100 & data$U3444100 <= 999.0] <- 900.0
data$U3444100[1000.0 <= data$U3444100 & data$U3444100 <= 1099.0] <- 1000.0
data$U3444100[1100.0 <= data$U3444100 & data$U3444100 <= 1199.0] <- 1100.0
data$U3444100[1200.0 <= data$U3444100 & data$U3444100 <= 1299.0] <- 1200.0
data$U3444100[1300.0 <= data$U3444100 & data$U3444100 <= 1399.0] <- 1300.0
data$U3444100[1400.0 <= data$U3444100 & data$U3444100 <= 1499.0] <- 1400.0
data$U3444100[1500.0 <= data$U3444100 & data$U3444100 <= 1599.0] <- 1500.0
data$U3444100[1600.0 <= data$U3444100 & data$U3444100 <= 1699.0] <- 1600.0
data$U3444100[1700.0 <= data$U3444100 & data$U3444100 <= 1799.0] <- 1700.0
data$U3444100[1800.0 <= data$U3444100 & data$U3444100 <= 1899.0] <- 1800.0
data$U3444100[1900.0 <= data$U3444100 & data$U3444100 <= 1999.0] <- 1900.0
data$U3444100[2000.0 <= data$U3444100 & data$U3444100 <= 2999.0] <- 2000.0
data$U3444100[3000.0 <= data$U3444100 & data$U3444100 <= 9999.0] <- 3000.0
data$U3444100 <- factor(data$U3444100,
levels=c(0.0,1.0,100.0,200.0,300.0,400.0,500.0,600.0,700.0,800.0,900.0,1000.0,1100.0,1200.0,1300.0,1400.0,1500.0,1600.0,1700.0,1800.0,1900.0,2000.0,3000.0),
labels=c("0",
"1 TO 99: .01-.99",
"100 TO 199: 1.00-1.99",
"200 TO 299: 2.00-2.99",
"300 TO 399: 3.00-3.99",
"400 TO 499: 4.00-4.99",
"500 TO 599: 5.00-5.99",
"600 TO 699: 6.00-6.99",
"700 TO 799: 7.00-7.99",
"800 TO 899: 8.00-8.99",
"900 TO 999: 9.00-9.99",
"1000 TO 1099: 10.00-10.99",
"1100 TO 1199: 11.00-11.99",
"1200 TO 1299: 12.00-12.99",
"1300 TO 1399: 13.00-13.99",
"1400 TO 1499: 14.00-14.99",
"1500 TO 1599: 15.00-15.99",
"1600 TO 1699: 16.00-16.99",
"1700 TO 1799: 17.00-17.99",
"1800 TO 1899: 18.00-18.99",
"1900 TO 1999: 19.00-19.99",
"2000 TO 2999: 20.00-29.99",
"3000 TO 9999: 30.00+"))
data$U3444200[20.0 <= data$U3444200 & data$U3444200 <= 99.0] <- 20.0
data$U3444200 <- factor(data$U3444200,
levels=c(0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0,16.0,17.0,18.0,19.0,20.0),
labels=c("0",
"1",
"2",
"3",
"4",
"5",
"6",
"7",
"8",
"9",
"10",
"11",
"12",
"13",
"14",
"15",
"16",
"17",
"18",
"19",
"20 TO 99: 20+"))
data$U3451900[10.0 <= data$U3451900 & data$U3451900 <= 999.0] <- 10.0
data$U3451900 <- factor(data$U3451900,
levels=c(0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0),
labels=c("0",
"1",
"2",
"3",
"4",
"5",
"6",
"7",
"8",
"9",
"10 TO 999: 10+"))
data$U3452000[10.0 <= data$U3452000 & data$U3452000 <= 999.0] <- 10.0
data$U3452000 <- factor(data$U3452000,
levels=c(0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0),
labels=c("0",
"1",
"2",
"3",
"4",
"5",
"6",
"7",
"8",
"9",
"10 TO 999: 10+"))
data$U3453800[1.0 <= data$U3453800 & data$U3453800 <= 9.0] <- 1.0
data$U3453800[10.0 <= data$U3453800 & data$U3453800 <= 19.0] <- 10.0
data$U3453800[20.0 <= data$U3453800 & data$U3453800 <= 29.0] <- 20.0
data$U3453800[30.0 <= data$U3453800 & data$U3453800 <= 39.0] <- 30.0
data$U3453800[40.0 <= data$U3453800 & data$U3453800 <= 49.0] <- 40.0
data$U3453800[50.0 <= data$U3453800 & data$U3453800 <= 59.0] <- 50.0
data$U3453800[60.0 <= data$U3453800 & data$U3453800 <= 69.0] <- 60.0
data$U3453800[70.0 <= data$U3453800 & data$U3453800 <= 79.0] <- 70.0
data$U3453800[80.0 <= data$U3453800 & data$U3453800 <= 89.0] <- 80.0
data$U3453800[90.0 <= data$U3453800 & data$U3453800 <= 99.0] <- 90.0
data$U3453800[100.0 <= data$U3453800 & data$U3453800 <= 124.0] <- 100.0
data$U3453800[125.0 <= data$U3453800 & data$U3453800 <= 149.0] <- 125.0
data$U3453800[150.0 <= data$U3453800 & data$U3453800 <= 174.0] <- 150.0
data$U3453800[175.0 <= data$U3453800 & data$U3453800 <= 199.0] <- 175.0
data$U3453800[200.0 <= data$U3453800 & data$U3453800 <= 249.0] <- 200.0
data$U3453800[250.0 <= data$U3453800 & data$U3453800 <= 299.0] <- 250.0
data$U3453800[300.0 <= data$U3453800 & data$U3453800 <= 349.0] <- 300.0
data$U3453800[350.0 <= data$U3453800 & data$U3453800 <= 399.0] <- 350.0
data$U3453800[400.0 <= data$U3453800 & data$U3453800 <= 449.0] <- 400.0
data$U3453800[450.0 <= data$U3453800 & data$U3453800 <= 499.0] <- 450.0
data$U3453800[500.0 <= data$U3453800 & data$U3453800 <= 2000.0] <- 500.0
data$U3453800 <- factor(data$U3453800,
levels=c(0.0,1.0,10.0,20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0,125.0,150.0,175.0,200.0,250.0,300.0,350.0,400.0,450.0,500.0),
labels=c("0",
"1 TO 9",
"10 TO 19",
"20 TO 29",
"30 TO 39",
"40 TO 49",
"50 TO 59",
"60 TO 69",
"70 TO 79",
"80 TO 89",
"90 TO 99",
"100 TO 124",
"125 TO 149",
"150 TO 174",
"175 TO 199",
"200 TO 249",
"250 TO 299",
"300 TO 349",
"350 TO 399",
"400 TO 449",
"450 TO 499",
"500 TO 2000: 500+"))
data$U4112100[1.0 <= data$U4112100 & data$U4112100 <= 10.0] <- 1.0
data$U4112100[11.0 <= data$U4112100 & data$U4112100 <= 20.0] <- 11.0
data$U4112100[21.0 <= data$U4112100 & data$U4112100 <= 30.0] <- 21.0
data$U4112100[31.0 <= data$U4112100 & data$U4112100 <= 40.0] <- 31.0
data$U4112100[41.0 <= data$U4112100 & data$U4112100 <= 50.0] <- 41.0
data$U4112100[51.0 <= data$U4112100 & data$U4112100 <= 60.0] <- 51.0
data$U4112100[61.0 <= data$U4112100 & data$U4112100 <= 70.0] <- 61.0
data$U4112100[71.0 <= data$U4112100 & data$U4112100 <= 80.0] <- 71.0
data$U4112100[81.0 <= data$U4112100 & data$U4112100 <= 90.0] <- 81.0
data$U4112100[91.0 <= data$U4112100 & data$U4112100 <= 100.0] <- 91.0
data$U4112100 <- factor(data$U4112100,
levels=c(0.0,1.0,11.0,21.0,31.0,41.0,51.0,61.0,71.0,81.0,91.0),
labels=c("0: 0%",
"1 TO 10: 1%-10%",
"11 TO 20: 11%-20%",
"21 TO 30: 21%-30%",
"31 TO 40: 31%-40%",
"41 TO 50: 41%-50%",
"51 TO 60: 51%-60%",
"61 TO 70: 61%-70%",
"71 TO 80: 71%-80%",
"81 TO 90: 81%-90%",
"91 TO 100: 91%-100%"))
data$U4282300[1.0 <= data$U4282300 & data$U4282300 <= 4999.0] <- 1.0
data$U4282300[5000.0 <= data$U4282300 & data$U4282300 <= 9999.0] <- 5000.0
data$U4282300[10000.0 <= data$U4282300 & data$U4282300 <= 14999.0] <- 10000.0
data$U4282300[15000.0 <= data$U4282300 & data$U4282300 <= 19999.0] <- 15000.0
data$U4282300[20000.0 <= data$U4282300 & data$U4282300 <= 24999.0] <- 20000.0
data$U4282300[25000.0 <= data$U4282300 & data$U4282300 <= 29999.0] <- 25000.0
data$U4282300[30000.0 <= data$U4282300 & data$U4282300 <= 39999.0] <- 30000.0
data$U4282300[40000.0 <= data$U4282300 & data$U4282300 <= 49999.0] <- 40000.0
data$U4282300[50000.0 <= data$U4282300 & data$U4282300 <= 59999.0] <- 50000.0
data$U4282300[60000.0 <= data$U4282300 & data$U4282300 <= 69999.0] <- 60000.0
data$U4282300[70000.0 <= data$U4282300 & data$U4282300 <= 79999.0] <- 70000.0
data$U4282300[80000.0 <= data$U4282300 & data$U4282300 <= 89999.0] <- 80000.0
data$U4282300[90000.0 <= data$U4282300 & data$U4282300 <= 99999.0] <- 90000.0
data$U4282300[100000.0 <= data$U4282300 & data$U4282300 <= 149999.0] <- 100000.0
data$U4282300[150000.0 <= data$U4282300 & data$U4282300 <= 9.9999999E7] <- 150000.0
data$U4282300 <- factor(data$U4282300,
levels=c(0.0,1.0,5000.0,10000.0,15000.0,20000.0,25000.0,30000.0,40000.0,50000.0,60000.0,70000.0,80000.0,90000.0,100000.0,150000.0),
labels=c("0",
"1 TO 4999",
"5000 TO 9999",
"10000 TO 14999",
"15000 TO 19999",
"20000 TO 24999",
"25000 TO 29999",
"30000 TO 39999",
"40000 TO 49999",
"50000 TO 59999",
"60000 TO 69999",
"70000 TO 79999",
"80000 TO 89999",
"90000 TO 99999",
"100000 TO 149999",
"150000 TO 99999999: 150000+"))
data$U4368100[1.0 <= data$U4368100 & data$U4368100 <= 24.0] <- 1.0
data$U4368100[25.0 <= data$U4368100 & data$U4368100 <= 49.0] <- 25.0
data$U4368100[50.0 <= data$U4368100 & data$U4368100 <= 74.0] <- 50.0
data$U4368100[75.0 <= data$U4368100 & data$U4368100 <= 99.0] <- 75.0
data$U4368100[100.0 <= data$U4368100 & data$U4368100 <= 124.0] <- 100.0
data$U4368100[125.0 <= data$U4368100 & data$U4368100 <= 149.0] <- 125.0
data$U4368100[150.0 <= data$U4368100 & data$U4368100 <= 174.0] <- 150.0
data$U4368100[175.0 <= data$U4368100 & data$U4368100 <= 199.0] <- 175.0
data$U4368100[200.0 <= data$U4368100 & data$U4368100 <= 224.0] <- 200.0
data$U4368100[225.0 <= data$U4368100 & data$U4368100 <= 249.0] <- 225.0
data$U4368100[250.0 <= data$U4368100 & data$U4368100 <= 9.9999999E7] <- 250.0
data$U4368100 <- factor(data$U4368100,
levels=c(0.0,1.0,25.0,50.0,75.0,100.0,125.0,150.0,175.0,200.0,225.0,250.0),
labels=c("0",
"1 TO 24",
"25 TO 49",
"50 TO 74",
"75 TO 99",
"100 TO 124",
"125 TO 149",
"150 TO 174",
"175 TO 199",
"200 TO 224",
"225 TO 249",
"250 TO 99999999: 250+"))
return(data)
}

varlabels <- c("PUBID - YTH ID CODE 1997",
"CV_AGE_INT_DATE 2019",
"CV_CENSUS_REGION 2019",
"CV_INCOME_FAMILY 2019",
"CV_HH_POV_RATIO 2019",
"CV_HH_SIZE 2019",
"CV_HIGHEST_DEGREE_EVER 2019",
"CV_MARSTAT 2019",
"CV_MSA 2019",
"CV_BIO_CHILD_HH_U18 2019",
"CV_BIO_CHILD_NR_U18 2019",
"CV_URBAN-RURAL 2019",
"CV_WKSWK_DLI_ALL 2019",
"DATE OF INTERVIEW STATUS - EMPLOYED 2019",
"% CHNC R WORKS > 20HRS WK IN A YEAR 2019",
"R RCV INC FROM JOB PAST YR? 2019",
"TTL INC WAGES, SALARY PAST YR 2019",
"R/SP RECEIVE INCOME FROM GOVERNMENT PROGRAMS? 2019",
"HOW R'S GENERAL HEALTH? 2019",
"R'S WEIGHT - POUNDS 2019",
"SUFFER FROM CHRONIC PAIN IN LAST 30 DAYS? 2019",
"R LMTD IN KIND OF WRK BECAUSE OF HLTH 2019",
"R LMTD IN AMT OF WRK BECAUSE OF HLTH 2019",
"PAST 12 MOS INJURED 2019",
"PAST 12 MOS EXP MENT HLTH PROB 2019",
"R HAVE ANY HEALTH CARE COVERAGE 2019",
"CESD - DEPRESSION 2019"
)


# Use qnames rather than rnums

qnames = function(data) {
names(data) <- c("PUBID_1997",
"CV_AGE_INT_DATE_2019",
"CV_CENSUS_REGION_2019",
"CV_INCOME_FAMILY_2019",
"CV_HH_POV_RATIO_2019",
"CV_HH_SIZE_2019",
"CV_HIGHEST_DEGREE_EVER_EDT_2019",
"CV_MARSTAT_2019",
"CV_MSA_2019",
"CV_BIO_CHILD_HH_U18_2019",
"CV_BIO_CHILD_NR_U18_2019",
"CV_URBAN-RURAL_2019",
"CV_WKSWK_DLI_ALL_2019",
"CV_DOI_EMPLOYED_2019",
"PERC_CHANCE_20+_HRS_JOB_NEXT_YR",
"ANY_INCOME_FROM_JOB_PAST_YR",
"TOTAL_INCOME",
"INCOME_FROM_GOV",
"OVR_HEALTH",
"WEIGHT",
"PAST_MONTH_CHRONIC_PAIN",
"KIND_WORK_HEALTH_LIM",
"AMT_WORK_HEALTH_LIM",
"PAST_YR_TIMES_INJURED",
"EMOTIONAL_HEALTH_ISSUE",
"HAS_HEALTH_CARE_COVERAGE/INSURANCE",
"CESD - DEPRESSION 2019")
return(data)
}


#********************************************************************************************************

# Remove the '#' before the following line to create a data file called "categories" with value labels.
categories <- vallabels(new_data)

# Remove the '#' before the following lines to rename variables using Qnames instead of Reference Numbers
new_data <- qnames(new_data)
categories <- qnames(categories)

# Produce summaries for the raw (uncategorized) data file
summary(new_data)

# Remove the '#' before the following lines to produce summaries for the "categories" data file.
categories <- vallabels(new_data)
categories <- vallabels_continuous(new_data)
#summary(categories)

#************************************************************************************************************

# keep rows with no NA's
clean_categories = categories[complete.cases(categories),]
clean_factorlvl_data = new_data[complete.cases(new_data),]

# write thes DFs to CSV files
# write.csv(clean_categories, "clean_categories.csv", row.names = FALSE)
# write.csv(clean_factorlvl_data, "clean_factorlvl_data.csv", row.names = FALSE)


# make factor variable of whether person has depression or not
# Respondents who said none to moderate categorized as not depressed,
# Those who said 5-7 days a week categorized as depressed.
clean_categories$Depression = ifelse(clean_categories$`CESD - DEPRESSION 2019` == "Most/All of the time/ 5-7 Days", 1, 0)



# take out unnecessary variables
clean_categories_dep <- select(clean_categories, -c("PUBID_1997", "ANY_INCOME_FROM_JOB_PAST_YR", "CESD - DEPRESSION 2019", "EMOTIONAL_HEALTH_ISSUE"))
names(clean_categories_dep) <- make.names(names(clean_categories_dep))
clean_categories_dep$CV_AGE_INT_DATE_2019 <- as.numeric(levels(clean_categories_dep$CV_AGE_INT_DATE_2019))[clean_categories_dep$CV_AGE_INT_DATE_2019]
dummy <- dummyVars("~.", data = clean_categories_dep)
clean_categories_dep <- data.frame(predict(dummy, newdata = clean_categories_dep))
clean_categories_dep$Depression <- as.factor(clean_categories_dep$Depression)
clean_categories_dep <- select(clean_categories_dep, -c("CV_CENSUS_REGION_2019.Northeast..CT..ME..MA..NH..NJ..NY..PA..RI..VT.", 
                                                    "CV_HIGHEST_DEGREE_EVER_EDT_2019.Professional.degree..DDS..JD..MD.",
                                                    "CV_MARSTAT_2019.Widowed..not.cohabiting",
                                                    "CV_MSA_2019.In.CBSA..not.known",
                                                    "CV_URBAN.RURAL_2019.Unknown",
                                                    "CV_DOI_EMPLOYED_2019.Military.service..but.no.job..reported",
                                                    "OVR_HEALTH.Poor",
                                                    "INCOME_FROM_GOV.YES",
                                                    "PAST_MONTH_CHRONIC_PAIN.YES",
                                                    "KIND_WORK_HEALTH_LIM.YES",
                                                    "AMT_WORK_HEALTH_LIM.YES",
                                                    "PAST_YR_TIMES_INJURED.NONE",
                                                    "HAS_HEALTH_CARE_COVERAGE.INSURANCE.YES",
                                                    "CV_MSA_2019.Not.in.country"
                                                    ))

colnames(clean_categories_dep)


# write.csv(clean_categories, "clean_categories_dep.csv", row.names = FALSE)
# fit logistic regression model.

#Create training and test set
set.seed(1) #set.seed(2)
train = sample(dim(clean_categories_dep)[1], dim(clean_categories_dep)[1]*0.75)
Depression.train=clean_categories_dep[train,]
Depression.test=clean_categories_dep[-train,]


# create model trained on training set
dep.full <- glm(Depression ~ ., family = binomial, data = Depression.train)
summary(dep.full)

# evaluate test set accuracy
pred.prob=predict(dep.full, Depression.test)
pred.dep=rep( "0", dim(Depression.test)[1] )
pred.dep[pred.prob>.5]="1"
tab = table(pred.dep,Depression.test$Depression) #Confusion Matrix
tab                     
sum(diag(tab))/sum(tab)

# Look at important variables
importantVars <- varImp(dep.full) %>%
  arrange(desc(Overall)) %>%
  top_n(10)

importantVars

table(clean_categories_dep$Depression)



################## LASSO model #########################

library(glmnet)

# Lasso Regression
# tune lambda parameter

colnames(newDepression.train)

set.seed(123) 
newDepression.train <- Depression.train[,-c(50)]
newDepression.train <- newDepression.train %>% mutate_at((c("CV_AGE_INT_DATE_2019", 
                                                            "CV_INCOME_FAMILY_2019", 
                                                            "CV_HH_POV_RATIO_2019", 
                                                            "CV_HH_SIZE_2019",
                                                            "CV_WKSWK_DLI_ALL_2019",
                                                            "PERC_CHANCE_20._HRS_JOB_NEXT_YR",
                                                            "TOTAL_INCOME",
                                                            "WEIGHT")), ~(scale(.) %>% as.vector))

table(Depression.train$Depression)
newDepression.train <- data.matrix(newDepression.train)
cvlasso <- cv.glmnet(newDepression.train, Depression.train$Depression, family = "binomial", alpha = 1)
laslambda = cvlasso$lambda.min
laslambda

coefList <- coef(cvlasso, s=laslambda)
coefList

coefList <- data.frame(coefList@Dimnames[[1]][coefList@i+1],coefList@x)
names(coefList) <- c('var','val')

coefList %>%
  arrange(-abs(val))

################ NEW DATA WITH IMPORTANT VARS ##########################
train = sample(dim(clean_categories_dep)[1], dim(clean_categories_dep)[1]*0.75)
Depression.train=clean_categories_dep[train,]
Depression.test=clean_categories_dep[-train,]

Dep.train.reduced <- select(Depression.train, c("INCOME_FROM_GOV.NO",
                                                "CV_MARSTAT_2019.Married..spouse.absent",
                                                "OVR_HEALTH.Fair",
                                                "CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job",
                                                "AMT_WORK_HEALTH_LIM.NO",
                                                "PAST_MONTH_CHRONIC_PAIN.NO",
                                                "CV_MARSTAT_2019.Separated..not.cohabiting",
                                                "PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES",
                                                "OVR_HEALTH.Good",
                                                "OVR_HEALTH.Very.good",
                                                "KIND_WORK_HEALTH_LIM.NO",
                                                "CV_INCOME_FAMILY_2019",
                                                "CV_HIGHEST_DEGREE_EVER_EDT_2019.Associate.Junior.college..AA.",
                                                "CV_HH_SIZE_2019",
                                                "CV_HIGHEST_DEGREE_EVER_EDT_2019.GED",
                                                "CV_BIO_CHILD_NR_U18_2019",
                                                "WEIGHT",
                                                "Depression"))

Dep.test.reduced <- select(Depression.test, c("INCOME_FROM_GOV.NO",
                                                "CV_MARSTAT_2019.Married..spouse.absent",
                                                "OVR_HEALTH.Fair",
                                                "CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job",
                                                "AMT_WORK_HEALTH_LIM.NO",
                                                "PAST_MONTH_CHRONIC_PAIN.NO",
                                                "CV_MARSTAT_2019.Separated..not.cohabiting",
                                                "PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES",
                                                "OVR_HEALTH.Good",
                                                "OVR_HEALTH.Very.good",
                                                "KIND_WORK_HEALTH_LIM.NO",
                                                "CV_INCOME_FAMILY_2019",
                                                "CV_HIGHEST_DEGREE_EVER_EDT_2019.Associate.Junior.college..AA.",
                                                "CV_HH_SIZE_2019",
                                                "CV_HIGHEST_DEGREE_EVER_EDT_2019.GED",
                                                "CV_BIO_CHILD_NR_U18_2019",
                                                "WEIGHT",
                                                "Depression"))

#### REDUCED LOG REG MODEL ####

dep.reduced <- glm(Depression ~ ., family = binomial, data = Dep.train.reduced)
summary(dep.reduced)

# evaluate test set accuracy
pred.prob=predict(dep.reduced, Dep.test.reduced)
pred.dep=rep( "0", dim(Dep.test.reduced)[1] )
pred.dep[pred.prob>.5]="1"
tab = table(pred.dep,Dep.test.reduced$Depression) #Confusion Matrix
tab                     
sum(diag(tab))/sum(tab)

# Look at important variables
importantVars <- varImp(dep.full) %>%
  arrange(desc(Overall)) %>%
  top_n(10)

importantVars


######### SMOTE logistic reg ########################


table(clean_categories_dep$Depression)

SMOTE_dep <- smote(Depression ~ ., clean_categories_dep, k = 5, perc.over = 30, perc.under = 2)

SMOTE_dep <- select(SMOTE_dep, c("INCOME_FROM_GOV.NO",
                                              "CV_MARSTAT_2019.Married..spouse.absent",
                                              "OVR_HEALTH.Fair",
                                              "CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job",
                                              "AMT_WORK_HEALTH_LIM.NO",
                                              "PAST_MONTH_CHRONIC_PAIN.NO",
                                              "CV_MARSTAT_2019.Separated..not.cohabiting",
                                              "PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES",
                                              "OVR_HEALTH.Good",
                                              "OVR_HEALTH.Very.good",
                                              "KIND_WORK_HEALTH_LIM.NO",
                                              "CV_INCOME_FAMILY_2019",
                                              "CV_HIGHEST_DEGREE_EVER_EDT_2019.Associate.Junior.college..AA.",
                                              "CV_HH_SIZE_2019",
                                              "CV_HIGHEST_DEGREE_EVER_EDT_2019.GED",
                                              "CV_BIO_CHILD_NR_U18_2019",
                                              "WEIGHT",
                                              "Depression"))

Reduced_original_data <- select(clean_categories_dep, c("INCOME_FROM_GOV.NO",
                                 "CV_MARSTAT_2019.Married..spouse.absent",
                                 "OVR_HEALTH.Fair",
                                 "CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job",
                                 "AMT_WORK_HEALTH_LIM.NO",
                                 "PAST_MONTH_CHRONIC_PAIN.NO",
                                 "CV_MARSTAT_2019.Separated..not.cohabiting",
                                 "PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES",
                                 "OVR_HEALTH.Good",
                                 "OVR_HEALTH.Very.good",
                                 "KIND_WORK_HEALTH_LIM.NO",
                                 "CV_INCOME_FAMILY_2019",
                                 "CV_HIGHEST_DEGREE_EVER_EDT_2019.Associate.Junior.college..AA.",
                                 "CV_HH_SIZE_2019",
                                 "CV_HIGHEST_DEGREE_EVER_EDT_2019.GED",
                                 "CV_BIO_CHILD_NR_U18_2019",
                                 "WEIGHT",
                                 "Depression"))
table(SMOTE_dep$Depression)
table(Reduced_original_data$Depression)

############################## VISUALIZATIONS OF SMOTE VS REAL DATA ##########################

library(patchwork)
library(ggplot2)


# inujured 4 times
p1<-ggplot(data= clean_categories_dep, aes(fill = Depression, x=Reduced_original_data$PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES)) +
  geom_bar(position = "dodge", stat="count", width = 0.5)+
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
  labs(title = "Original Data", 
         y = "Count",
         x = "Injured 4 or more times in 2019")

p1

p2<-ggplot(data= SMOTE_dep, aes(fill = Depression, x=SMOTE_dep$PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES)) +
  geom_bar(position = "dodge", stat="count", width = 0.5)+
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+ 
  labs(title = "SMOTE Data", 
     y = "Count",
     x = "Injured 4 or more times in 2019")

# Household size
p3<-ggplot(data= clean_categories_dep, aes(fill = Depression, x=Reduced_original_data$CV_HH_SIZE_2019)) +
  geom_bar(position = "dodge", stat="count", width = 0.5)+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+ 
  labs(title = "Original Data", 
         y = "Count",
         x = "Household Size 2019")

p4<-ggplot(data= SMOTE_dep, aes(fill = Depression, x=SMOTE_dep$CV_HH_SIZE_2019)) +
  geom_bar(position = "dodge", stat="count", width = 0.5)+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+
  labs(title = "SMOTE Data", 
         y = "Count",
         x = "Household Size 2019")


# Not employed 
p5<-ggplot(data= clean_categories_dep, aes(fill = Depression, x=Reduced_original_data$CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job)) +
  geom_bar(position = "dodge", stat="count", width = 0.5)+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+ 
  labs(title = "Original Data", 
         y = "Count",
         x = "Not Currently Working")

p6<-ggplot(data= SMOTE_dep, aes(fill = Depression, x=SMOTE_dep$CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job)) +
  geom_bar(position = "dodge", stat="count", width = 0.5)+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))+ 
  labs(title = "SMOTE Data", 
        y = "Count",
        x = "Not Currently Working")

((p1|p2) / (p3|p4) / (p5|p6))

ggarrange(p1, p2, p3, p4, p5, p6, ncol = 2, nrow = 3)


############################## SMOTE MODEL 1 ########################################################


#Create training and test set
set.seed(1) #set.seed(2)
train = sample(dim(SMOTE_dep)[1], dim(SMOTE_dep)[1]*0.75)
Depression.train.smote =SMOTE_dep[train,]
Depression.test.smote =SMOTE_dep[-train,]

# create model trained on training set
dep.full.smote <- glm(Depression ~ ., family = binomial, data = Depression.train.smote)
summary(dep.full.smote)

# evaluate test set accuracy
pred.prob=predict(dep.full.smote, Depression.test.smote)
pred.dep=rep( "0", dim(Depression.test.smote)[1] )
pred.dep[pred.prob>.5]="1"
tab = table(pred.dep,Depression.test.smote$Depression) #Confusion Matrix
tab                     
sum(diag(tab))/sum(tab)

tab[4]/(tab[3] + tab[4])

# Look at important variables
importantVars <- varImp(dep.full.smote) %>%
  arrange(desc(Overall)) %>%
  top_n(10)

importantVars

table(clean_categories_dep$Depression)


############################## SMOTE MODEL 2 ########################################################

table(clean_categories_dep$Depression)

SMOTE_dep <- smote(Depression ~ ., clean_categories_dep, k = 4, perc.over = 100, perc.under = 2)

SMOTE_dep <- select(SMOTE_dep, c("INCOME_FROM_GOV.NO",
                                 "CV_MARSTAT_2019.Married..spouse.absent",
                                 "OVR_HEALTH.Fair",
                                 "CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job",
                                 "AMT_WORK_HEALTH_LIM.NO",
                                 "PAST_MONTH_CHRONIC_PAIN.NO",
                                 "CV_MARSTAT_2019.Separated..not.cohabiting",
                                 "PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES",
                                 "OVR_HEALTH.Good",
                                 "OVR_HEALTH.Very.good",
                                 "KIND_WORK_HEALTH_LIM.NO",
                                 "CV_INCOME_FAMILY_2019",
                                 "CV_HIGHEST_DEGREE_EVER_EDT_2019.Associate.Junior.college..AA.",
                                 "CV_HH_SIZE_2019",
                                 "CV_HIGHEST_DEGREE_EVER_EDT_2019.GED",
                                 "CV_BIO_CHILD_NR_U18_2019",
                                 "WEIGHT",
                                 "Depression"))

# adds 15/100 times the amount of 

table(SMOTE_dep$Depression)

#Create training and test set
set.seed(1) #set.seed(2)
train = sample(dim(SMOTE_dep)[1], dim(SMOTE_dep)[1]*0.75)
Depression.train.smote =SMOTE_dep[train,]
Depression.test.smote =SMOTE_dep[-train,]

# create model trained on training set
dep.full.smote <- glm(Depression ~ ., family = binomial, data = Depression.train.smote)
summary(dep.full.smote)

# evaluate test set accuracy
pred.prob=predict(dep.full.smote, Depression.test.smote)
pred.dep=rep( "0", dim(Depression.test.smote)[1] )
pred.dep[pred.prob>.5]="1"
tab = table(pred.dep,Depression.test.smote$Depression) #Confusion Matrix
tab                     
sum(diag(tab))/sum(tab)

tab[4]/(tab[3] + tab[4])

# Look at important variables
importantVars <- varImp(dep.full.smote) %>%
  arrange(desc(Overall)) %>%
  top_n(10)

importantVars

############################## SMOTE MODEL 3 ########################################################



table(clean_categories_dep$Depression)

SMOTE_dep <- smote(Depression ~ ., clean_categories_dep, k = 5, perc.over = 25, perc.under = 1.05)

SMOTE_dep <- select(SMOTE_dep, c("INCOME_FROM_GOV.NO",
                                 "CV_MARSTAT_2019.Married..spouse.absent",
                                 "OVR_HEALTH.Fair",
                                 "CV_DOI_EMPLOYED_2019.Not.currently.working.at.a.job",
                                 "AMT_WORK_HEALTH_LIM.NO",
                                 "PAST_MONTH_CHRONIC_PAIN.NO",
                                 "CV_MARSTAT_2019.Separated..not.cohabiting",
                                 "PAST_YR_TIMES_INJURED.4.OR.MORE.TIMES",
                                 "OVR_HEALTH.Good",
                                 "OVR_HEALTH.Very.good",
                                 "KIND_WORK_HEALTH_LIM.NO",
                                 "CV_INCOME_FAMILY_2019",
                                 "CV_HIGHEST_DEGREE_EVER_EDT_2019.Associate.Junior.college..AA.",
                                 "CV_HH_SIZE_2019",
                                 "CV_HIGHEST_DEGREE_EVER_EDT_2019.GED",
                                 "CV_BIO_CHILD_NR_U18_2019",
                                 "WEIGHT",
                                 "Depression"))

table(SMOTE_dep$Depression)

#Create training and test set
set.seed(1) #set.seed(2)
train = sample(dim(SMOTE_dep)[1], dim(SMOTE_dep)[1]*0.75)
Depression.train.smote =SMOTE_dep[train,]
Depression.test.smote =SMOTE_dep[-train,]

# create model trained on training set
dep.25.smote <- glm(Depression ~ ., family = binomial, data = Depression.train.smote)
summary(dep.full.smote)

# evaluate test set accuracy
pred.prob=predict(dep.25.smote, Depression.test.smote)
pred.dep=rep( "0", dim(Depression.test.smote)[1] )
pred.dep[pred.prob>.5]="1"
tab = table(pred.dep,Depression.test.smote$Depression) #Confusion Matrix
tab                     
sum(diag(tab))/sum(tab)

tab[4]/(tab[3] + tab[4])

# Look at important variables
importantVars <- varImp(dep.25.smote) %>%
  arrange(desc(Overall)) %>%
  top_n(10)

importantVars

# mcfadden's r sq
nullmod = glm(Depression ~ 1, family=binomial, data=Depression.train.smote)
logLik(nullmod)
logLik(dep.25.smote)
1-logLik(dep.25.smote)/logLik(nullmod)               #pseudo-Rsquare
as.numeric( 1-logLik(dep.25.smote)/logLik(nullmod) )


##### RANDOM FOREST
library(randomForest)
rf.dep= randomForest(Depression ~ ., data = Dep.train.reduced, mtry = 8, ntree = 500, importance = T)
rf.pred = predict(rf.dep, Dep.test.reduced)

#Get predictions on test set from random forest
tab <- table(rf.pred,Dep.test.reduced$Depression)
tab
(tab[1,1]+tab[2,2])/sum(tab) #% of correct predictions

importance(rf.dep)
varImpPlot(rf.dep)


##### SMOTE RF ######

# V1

rf.dep= randomForest(Depression ~ ., data = Depression.train.smote, mtry = 5, ntree = 100, importance = T)
rf.pred = predict(rf.dep, Depression.test.smote)

#Get predictions on test set from random forest
tab <- table(rf.pred,Depression.test.smote$Depression)
tab
(tab[1,1]+tab[2,2])/sum(tab) #% of correct predictions

tab[4]/(tab[3] + tab[4])

importance(rf.dep)
varImpPlot(rf.dep)


############ NAIVE BAYES #################
library(naivebayes)
library(psych)

library(e1071)
nb_default <- naiveBayes(Depression~., data=Depression.train.smote)
default_pred <- predict(nb_default, Depression.test.smote, type="class")

tab <- table(default_pred, Depression.test.smote$Depression,dnn=c("Prediction","Actual"))
tab
sum(diag(tab))/sum(tab)
