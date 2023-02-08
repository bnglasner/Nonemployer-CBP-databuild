# Ben Glasner
# County level Nonemployer data with CBSA Uber treatment
# 7/16/2019

##########################
#         Set Up         #  
##########################

library(readxl)
library(dplyr)
library(lubridate)
library(readstata13)

library(purrr)
library(stringr)

# source("http://jtilly.io/install_github/install_github.R")
# install_github("jtilly/cbpR")
# library("cbpR")

#################
### Set paths ###
#################
if(Sys.info()[["user"]]=="bglasner"){
  # Root folder
  path_project <- "C:/Users/bglasner/Dropbox"
}
if(Sys.info()[["user"]]=="bngla"){
  # Root folder
  path_project <- "C:/Users/bngla/Dropbox"
}
if(Sys.info()[["user"]]=="Benjamin Glasner"){
  # Root folder
  path_project <- "C:/Users/Benjamin Glasner/Dropbox"
}
# Path to saved cohort data 
path_data <- paste0(path_project,"\\EIG\\Noncompete\\Data")
# Path where matched samples should be saved 
path_output <- paste0(path_project,"\\EIG\\Noncompete\\Output")
# Path to saved cohort data 
path_cbp <- paste0(path_project,"\\EIG\\Noncompete\\Data\\CBP")

setwd(path_cbp)



# load in the CBP county data 2000 - 2017
files <- list.files(pattern="cbp*")
myfiles <- lapply(files, read.csv)

# for (i in seq_along(files)){
#   print(files[[i]])
#   test <- read.csv(files[[i]])
#   }

# Clean the data
for (i in seq_along(myfiles)) {
  print(files[[i]])
  myfiles[[i]] <- myfiles[[i]] %>% dplyr::select("fipstate","fipscty","naics","emp", "est",
                                                 "n1_4","n5_9","n10_19","n20_49","n50_99",
                                                 "n100_249","n250_499","n500_999","n1000","n1000_1",
                                                 "n1000_2","n1000_3","n1000_4") 
  myfiles[[i]]$YEAR.id <- 1999+i
}

# append NES data
CBP <- do.call(rbind, myfiles)
rm(myfiles) # clear out everything other than CBP

CBP$naics[CBP$naics=="------"] <- "00"
CBP <- CBP %>% mutate(naics_num = readr::parse_number(as.character(naics))) %>% filter(naics_num<10000)
CBP$naics <- CBP$naics_num
CBP$naics[CBP$naics==0] <- "00"
CBP$naics <- as.character(CBP$naics)

CBP <- CBP %>% select("fipstate","fipscty","naics","YEAR.id","emp", "est",
                  "n1_4","n5_9","n10_19","n20_49","n50_99",
                  "n100_249","n250_499","n500_999","n1000","n1000_1",
                  "n1000_2","n1000_3","n1000_4") 

CBP$st <- as.numeric(as.character(CBP$fipstate))         
CBP$cty <- as.numeric(as.character(CBP$fipscty))         

########  input 2017 HHI from 2016 HHI
CBP$n1_4 <- as.numeric(as.character(CBP$n1_4))
CBP$n5_9 <- as.numeric(as.character(CBP$n5_9))
CBP$n10_19 <- as.numeric(as.character(CBP$n10_19))
CBP$n20_49 <- as.numeric(as.character(CBP$n20_49))
CBP$n50_99 <- as.numeric(as.character(CBP$n50_99))
CBP$n100_249 <- as.numeric(as.character(CBP$n100_249))
CBP$n250_499 <- as.numeric(as.character(CBP$n250_499))
CBP$n500_999 <- as.numeric(as.character(CBP$n500_999))
CBP$n1000 <- as.numeric(as.character(CBP$n1000))
CBP$n1000_1 <- as.numeric(as.character(CBP$n1000_1))
CBP$n1000_2 <- as.numeric(as.character(CBP$n1000_2))
CBP$n1000_3 <- as.numeric(as.character(CBP$n1000_3))
CBP$n1000_4 <- as.numeric(as.character(CBP$n1000_4))

save(CBP, file = "CBP_2000_2020.RData")




