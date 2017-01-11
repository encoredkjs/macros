# =========================================================================================================
#  FUNCTION TO PLOT DATA FILES (1/2): IN A SPECIFIC TIME
# libraries
library(lubridate)
library(macros)

# parameter setting
FLAG_ONLY_HOME <- F
HOME_CHANNEL <- 1 # valid when FLAG_ONLY_HOME == TRUE

FILE_SEP <- "_"
FILE_FIRST_WORD <- "4076994667"
FILE_TYPE <- ".feather" # feather only

COUNTRY <- "JP"

# HOUSEHOLD_DIR <- "/home/sjlee/data/jpData/test1/feather/" # June 2016
HOUSEHOLD_DIR <- "/home/kjs/data/jp/jp_201612/teto/" # August 2016
TIME_PERIOD <- as.POSIXct('2016-12-05 16:00:00',tz='Asia/Seoul')%--% as.POSIXct('2016-12-05 16:20:00',tz='Asia/Seoul')
# TIME_PERIOD <- as.POSIXct('2016-07-17 08:30:00',tz='Asia/Seoul') %--% as.POSIXct('2016-07-17 09:30:00',tz='Asia/Seoul')

plotHousehold(FILE_SEP, FILE_FIRST_WORD, FILE_TYPE, HOUSEHOLD_DIR, TIME_PERIOD, FLAG_ONLY_HOME, COUNTRY, HOME_CHANNEL)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO PLOT DATA FILES (2/2): WHEN TURNED ON
# libraries
library(macros)

# parameter setting
METHOD <- "file" # "plot" # "file" # "both"

HOUSEHOLD_DIR <- "/home/kjs/data/jp/jp_201612/teto/"
RESULT_DIR <- "/home/kjs/data/jp/jp_201612/aircon_tepco/"
CHOSEN_APP <- "에어컨"

PLOT_NUM_MAX <- 20

AP_THRES_MIN <- 15 # IS NOT USED (i.e., USELESS)
AP_CONSIDERED_MAX <- 5000

showWhenAppIsOn(METHOD, HOUSEHOLD_DIR, RESULT_DIR, CHOSEN_APP, PLOT_NUM_MAX, AP_THRES_MIN, AP_CONSIDERED_MAX)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO EXAMINE NILM RESULTS (1/3)
# process RAW files
library(macros)
library(dplyr)
library(googlesheets)
options(httr_oob_default = TRUE)

# supplementary functions
targetGs <- gs_key(gs_ls('데이터 시리얼 관리표')$sheet_key)
userList <-
  gs_read(targetGs, ws = '메타정보관리-jp') %>% filter( grepl(pattern = "tepco", x = Owner))
names(userList) <- c("sn.parent", "ch.parent", "sn.dev", "ch.dev", "user", "division", "code", "x1", "x2","x3","x4","x5","x6","x7","x8")
userList <- userList %>% select(user, division, code, sn.parent, sn.dev)

# parameter setting
USER_LIST <- userList
DATA_DIR <- "/home/kjs/data/jp/jp_201612/teto/"
SOURCE_DIR <- "/disk3/raw_data_with_plug/jp-201612/"

# OBJ <- "home"
OBJ <- "plug"

CHOSEN_SITE_DEC <- c() # c(4093509610, 4093509620, 4093509618) # c()
CHOSEN_SITE_HEX <- c("F302006B")

CHOSEN_APP <- c("전자레인지")# c("세탁기","전기밥솥")

ID_START <- '20161201' # this parameter cannot choose proper duration (i.e., whole data is considered for a month)
ID_END   <- '20161231' # this parameter cannot choose proper duration (i.e., whole data is considered for a month)

IGNORE_EXIST_DATA <- TRUE

loadReportFiles(USER_LIST, SOURCE_DIR, DATA_DIR, OBJ, CHOSEN_SITE_DEC, CHOSEN_SITE_HEX, CHOSEN_APP, ID_START, ID_END, IGNORE_EXIST_DATA)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO EXAMINE NILM RESULTS (2/3)
# libraries
library(macros)

# parameter setting
DATA_DIR <- "/home/kjs/data/jp/jp_201610/yazaki/"

CHOSEN_APP <- "세탁기"

startTimestampForMeta <- "2016-10-01 00:00:00"
endTimestampForMeta <- "2016-10-15 00:00:00"

startTimestampForSummary <- NULL # "2016-10-01 00:00:00"
endTimestampForSummary <- NULL # "2016-10-15 00:00:00"

POWER_THRES <- 1

CHOSEN_SITE_DEC <- c() # c(4093509610, 4093509620, 4093509618)
CHOSEN_SITE_HEX <- c()

getSummaryWithMeta_NILM(DATA_DIR, CHOSEN_APP,
                        startTimestampForMeta, endTimestampForMeta,
                        startTimestampForSummary, endTimestampForSummary,
                        POWER_THRES, CHOSEN_SITE_DEC, CHOSEN_SITE_HEX)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO EXAMINE NILM RESULTS (3/3)
# libraries
library(macros)

# parameter setting
SUMMARY_DIR <- "/disk3/data_tmp/2017-01-05T05:49:06.065606/"
# SUMMARY_DIR <- "/disk3/data_tmp/2017-01-05T04:15:53.702929/"
SUMMARY_DIR <- "/disk3/data_tmp/2017-01-05T05:48:16.153141/"
FIGURE_FILE <- "HeatMap.png"
APP_NAME <- "세탁기"
# APP_NAME <- "전기밥솥"

getReport_NILM(SUMMARY_DIR, FIGURE_FILE, APP_NAME)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO CONVERT (ENCORED) STANDARD RAW NILM FILE INTO TEPCO & TOHOKU STANDARD (1/2)
#  note: This function has been merged to 'ForceManager'
# libraries
library(macros)
options(scipen = 20)

# parameter setting
SOURCE_DIR <- "/home/kjs/sample/"
SOURCE_FILE_TYPE <- "rds" # "csv"
DATA_DIR <- "/home/kjs/result/"

DATA_SUFFIX <- "2016-12"

convertNILMResultToTepcoSTD(SOURCE_DIR, SOURCE_FILE_TYPE, DATA_DIR, DATA_SUFFIX)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO CHECK INTEGRITY WITH TEPCO & TOHOKU STANDARD FILES (2/2)
# libraries
library(macros)
# options(scipen = 20)

DATA_DIR <- "/home/kjs/tepco_submission/"
WRITE_OUTPUT_FILE = TRUE
SAVED_OUTPUT_FILE_WITH_PATH <- "~/result_tepcoChk.txt"

checkIntegrityOfTepcoStdFiles(DATA_DIR, WRITE_OUTPUT_FILE, SAVED_OUTPUT_FILE_WITH_PATH)
# =========================================================================================================

# =========================================================================================================
# FUNCTION TO TYPE SYSTEM COMMAND USUALLY TO MODIFY FILES IN A FOLDER

# libraries
library(macros)
SOURCE_DIR <- "/Users/kjs/Desktop/NILM_tepco/tepco_submission/"
FILE_KEYWORD <- "NILM"
DATA_DIR <- "/Users/kjs/Desktop/TEPCO/2016-12/Encored_RawData/"

DO_FUNCTION <- "MODIFY_COLUMN_FOR_TEPCO"
DO_FUNCTION <- "MODIFY_FILE_NAME_FOR_TEPCO"
DO_FUNCTION <- "DISTRIBUTE_FILES_TO_EACH_FOLDER_FOR_TEPCO"


modifyFilesUsingSysCommand(SOURCE_DIR,
                           FILE_KEYWORD,
                           DATA_DIR,
                           DO_FUNCTION)
# =========================================================================================================

x <- fread("~/jsonForReport/tepcoSample/result/F3FDFFF1_NILM_1s_62_refrigerator1_2016-12")


