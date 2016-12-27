# =========================================================================================================
# libraries
library(lubridate)
library(macros)

# parameter setting
FLAG_ONLY_HOME <- T
HOME_CHANNEL <- 1 # valid when FLAG_ONLY_HOME == TRUE

FILE_SEP <- "_"
FILE_FIRST_WORD <- "11"
FILE_TYPE <- ".feather" # feather only

COUNTRY <- "JP"

# HOUSEHOLD_DIR <- "/home/sjlee/data/jpData/test1/feather/" # June 2016
HOUSEHOLD_DIR <- "/home/kjs/data/jp/files/" # August 2016
TIME_PERIOD <- as.POSIXct('2016-08-15 19:30:00',tz='Asia/Seoul') %--% as.POSIXct('2016-08-15 19:32:00',tz='Asia/Seoul')
# TIME_PERIOD <- as.POSIXct('2016-07-17 08:30:00',tz='Asia/Seoul') %--% as.POSIXct('2016-07-17 09:30:00',tz='Asia/Seoul')

plotHousehold(FILE_SEP, FILE_FIRST_WORD, FILE_TYPE, HOUSEHOLD_DIR, TIME_PERIOD, FLAG_ONLY_HOME, COUNTRY, HOME_CHANNEL)
# =========================================================================================================

# =========================================================================================================
# libraries
library(macros)

# parameter setting
SUMMARY_DIR <- "/disk3/data_tmp/2016-12-27T07:09:46.409208/"
FIGURE_FILE <- "HeatMap.png"
APP_NAME <- "세탁기"

getReport_NILM(SUMMARY_DIR, FIGURE_FILE, APP_NAME)
# =========================================================================================================




