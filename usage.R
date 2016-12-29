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
SUMMARY_DIR <- "/disk3/data_tmp/2016-12-27T07:08:12.396002/"
FIGURE_FILE <- "HeatMap.png"
APP_NAME <- "세탁기"

getReport_NILM(SUMMARY_DIR, FIGURE_FILE, APP_NAME)
# =========================================================================================================

# =========================================================================================================
# process RAW files
library(macros)
library(dplyr)
library(googlesheets)
options(httr_oob_default = TRUE)

# supplementary functions
targetGs <- gs_key(gs_ls('데이터 시리얼 관리표')$sheet_key)
userList <-
  gs_read(targetGs, ws = '메타정보관리-jp') # %>% filter( grepl(pattern = "야자키", x = Owner))
names(userList) <- c("sn.parent", "ch.parent", "sn.dev", "ch.dev", "user", "division", "code", "x1", "x2","x3","x4","x5","x6","x7","x8")
userList <- userList %>% select(user, division, code, sn.parent, sn.dev)

# parameter setting
USER_LIST <- userList
DATA_DIR <- "/home/kjs/data/jp/jp_201610/files_new/"
SOURCE_DIR <- "/disk3/raw_data_with_plug/jp-201610/"

OBJ <- "home"
# OBJ <- "plug"

CHOSEN_SITE_DEC <- c(4093509610, 4093509620, 4093509618) # c()
CHOSEN_SITE_HEX <- c()

CHOSEN_APP <- c("세탁기","전기밥솥")

ID_START <- '20161001' # this parameter cannot choose proper duration (i.e., whole data is considered for a month)
ID_END   <- '20161031' # this parameter cannot choose proper duration (i.e., whole data is considered for a month)

IGNORE_EXIST_DATA <- TRUE

loadReportFiles(USER_LIST, SOURCE_DIR, DATA_DIR, OBJ, CHOSEN_SITE_DEC, CHOSEN_SITE_HEX, CHOSEN_APP, ID_START, ID_END, IGNORE_EXIST_DATA)
# =========================================================================================================
