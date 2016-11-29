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

# HOUSEHOLD_DIR <- "/home/sjlee/data/jpData/test1/feather/" # June 2016
HOUSEHOLD_DIR <- "/home/kjs/data/jp/files/" # August 2016
TIME_PERIOD <- as.POSIXct('2016-08-15 19:30:00',tz='Asia/Seoul') %--% as.POSIXct('2016-08-15 19:32:00',tz='Asia/Seoul')
# TIME_PERIOD <- as.POSIXct('2016-07-17 08:30:00',tz='Asia/Seoul') %--% as.POSIXct('2016-07-17 09:30:00',tz='Asia/Seoul')


plotHousehold_jp(FILE_SEP, FILE_FIRST_WORD, FILE_TYPE, HOUSEHOLD_DIR, TIME_PERIOD, FLAG_ONLY_HOME, HOME_CHANNEL)
# =========================================================================================================
