# =========================================================================================================
#  FUNCTION TO PLOT DATA FILES (1/2): IN A SPECIFIC TIME
# libraries
library(lubridate)
library(macros)
library(MillenniumFalcon)

# parameter setting
FLAG_ONLY_HOME <- F
HOME_CHANNEL <- 1 # valid when FLAG_ONLY_HOME == TRUE

FILE_SEP <- "_"

# FILE_FIRST_WORD <- "4076994598"
# FILE_TYPE <- ".feather"
# HOUSEHOLD_DIR <- "~/data/kr/kr_201703/files/"

FILE_FIRST_WORD <- "data_A3001BD6_20170326-20170327"
FILE_TYPE <- ".csv"
HOUSEHOLD_DIR <- "/disk3/raw_data_with_plug/kr-201703/" #

# COUNTRY <- "JP"
COUNTRY <- "KR"

# HOUSEHOLD_DIR <- "/home/sjlee/data/jpData/test1/feather/" # June 2016


TIME_PERIOD <- as.POSIXct('2017-03-26 09:00:00',tz='Asia/Seoul') %--% as.POSIXct('2017-03-26 21:00:00',tz='Asia/Seoul')
# TIME_PERIOD <- as.POSIXct('2016-12-13 18:08:00',tz='Asia/Seoul')%--% as.POSIXct('2016-12-13 18:10:00',tz='Asia/Seoul')
# TIME_PERIOD <- as.POSIXct('2016-07-17 08:30:00',tz='Asia/Seoul') %--% as.POSIXct('2016-07-17 09:30:00',tz='Asia/Seoul')

plotHousehold(FILE_SEP, FILE_FIRST_WORD, FILE_TYPE, HOUSEHOLD_DIR, TIME_PERIOD, FLAG_ONLY_HOME, COUNTRY, HOME_CHANNEL)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO PLOT DATA FILES (2/2): WHEN TURNED ON
# libraries
library(macros)

# parameter setting
METHOD <- "both" # "plot" # "file" # "both"

HOUSEHOLD_DIR <- "/home/kjs/data/jp/jp_201702/files/"
RESULT_DIR <- "/home/kjs/data/jp/jp_201702/cookerOnInfo/"
CHOSEN_APP <- "전기밥솥" # "에어컨"

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
  gs_read(targetGs, ws = '메타정보관리-kr') # %>% filter( grepl(pattern = "야자키", x = Owner) | grepl(pattern = "薛", x = Owner))
                                            # !grepl(pattern = "tepco", x = Owner),
                                            # !grepl(pattern = "tohokuepco", x = Owner))

names(userList) <- c("sn.parent", "ch.parent", "sn.dev", "ch.dev", "user", "division", "code", "x1", "x2","x3","x4","x5","x6","x7","x8","x9")
userList <- userList %>% select(user, division, code, sn.parent, sn.dev)

# parameter setting
USER_LIST <- userList
DATA_DIR <- "/home/kjs/data/jp/jp_201702/files/"
SOURCE_DIR <- "/disk3/raw_data_with_plug/jp-201702/"

# OBJ <- "home"
OBJ <- "plug"

# COUNTRY <- "kr"
COUNTRY <- "jp"

CHOSEN_SITE_DEC <- c() # c(4093509610, 4093509620, 4093509618)
# CHOSEN_SITE_HEX <- c("F3FDFFB9", "F3FDFFEF", "F3FDFFF1", "F3FDFFF2", "F3FDFFF3", "F3FDFFF4", "F3FDFFF5", "F3FDFFFE", "F3FFF787", "F3FDFFEC")
CHOSEN_SITE_HEX <- c()

EXCLUDE_ID_DEC <- c() # FINE WITH PLUG SERIALS
EXCLUDE_ID_HEX <- c()

# CHOSEN_APP <- c("세탁기","전기밥솥", "에어컨")
CHOSEN_APP <- c("전기밥솥")

ID_START <- '20170201' # this parameter cannot choose proper duration (i.e., whole data is considered for a month)
ID_END   <- '20170228' # this parameter cannot choose proper duration (i.e., whole data is considered for a month)

IGNORE_EXIST_DATA <- TRUE

loadReportFiles(USER_LIST, SOURCE_DIR, DATA_DIR, OBJ, COUNTRY, CHOSEN_SITE_DEC, CHOSEN_SITE_HEX, EXCLUDE_ID_DEC,
                EXCLUDE_ID_HEX, CHOSEN_APP, ID_START, ID_END, IGNORE_EXIST_DATA)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO EXAMINE NILM RESULTS (2/3)
# libraries
library(macros)
library(ForceEvent)

# parameter setting
DATA_DIR <- "/home/kjs/data/jp/jp_201702/files/"

# CHOSEN_APP <- "세탁기"
CHOSEN_APP <- "에어컨"

# COUNTRY <- "kr"
COUNTRY <- "jp"

startTimestampForMeta <- "2017-02-11 00:00:00"
endTimestampForMeta <- "2017-02-21 00:00:00"

startTimestampForSummary <- "2017-02-10 00:00:00" # NULL # "2016-10-01 00:00:00"
endTimestampForSummary <- "2017-02-25 00:00:00" # NULL # "2016-10-15 00:00:00"

# POWER_THRES <- 1
POWER_THRES <- 5

CHOSEN_SITE_DEC <- c() # c(4076994606, 4076994672) # c(4093509610, 4093509620, 4093509618)
CHOSEN_SITE_HEX <- c()

getSummaryWithMeta_NILM(DATA_DIR, CHOSEN_APP, COUNTRY,
                        startTimestampForMeta, endTimestampForMeta,
                        startTimestampForSummary, endTimestampForSummary,
                        POWER_THRES, CHOSEN_SITE_DEC, CHOSEN_SITE_HEX)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO EXAMINE NILM RESULTS (3/3)
# libraries
library(macros)

# parameter setting
# SUMMARY_DIR <- "/disk3/data_tmp/2017-01-05T05:49:06.065606/"
# SUMMARY_DIR <- "/disk3/data_tmp/2017-01-05T04:15:53.702929/"
SUMMARY_DIR <- "~/report/result/kr_201703_washer_170426_newClust/summary/"
# SUMMARY_DIR <- "/home/kjs/data/jp/jp_201612/summary_에어컨_files/"
FIGURE_FILE <- "HeatMap.png"
APP_NAME <- "세탁기"
# APP_NAME <- "전기밥솥"
# APP_NAME <- "에어컨"

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
# SOURCE_DIR <- "~/data/storage/heavyLoads/"
SOURCE_DIR <- "/home/kjs/data/storage/microwave/"
FILE_KEYWORD <- "NILM"
DATA_DIR <- "/home/kjs/data/storage/microwave_typeFixed/"

DO_FUNCTION <- "MODIFY_FILE_NAME_AND_COLUMN_FOR_TEPCO"
# DO_FUNCTION <- "MODIFY_FILE_NAME_FOR_TEPCO"
# DO_FUNCTION <- "DISTRIBUTE_FILES_TO_EACH_FOLDER_FOR_TEPCO"

modifyFilesUsingSysCommand(SOURCE_DIR,
                           FILE_KEYWORD,
                           DATA_DIR,
                           DO_FUNCTION)
# =========================================================================================================

# =========================================================================================================
# FUNCTION TO CHECK OUT THE SIZE OF FUNCTIONS IN A PACKAGE

# in a project of a package,
library(macros)
devtools::load_all()
packageFunctionLengths("ForceEvent") -> fLength
sort(fLength,decreasing = T)
# =========================================================================================================

# =========================================================================================================
#  FUNCTION TO MAKE VARIOUS REPORTS FROM YIELDED SUMMARY
# libraries
library(macros)
library(destroyForce)
# library(dplyr)
library(stringr)

# parameter setting
SUMMARY_DIR <- "~/report/result/jp_201703_washer_170426_newClust"
# SUMMARY_DIR <- "/home/kjs/data/jp/jp_201612/summary_에어컨_files/"

APP_TYPE <- 67 # cooker
# APP_TYPE <- 67 # washer

makeVariousReport(SUMMARY_DIR, APP_TYPE)
print("CAUTION! REMOVE TEMP DIRECTORY AFTER WORK: rm -rf ****")
# =========================================================================================================
