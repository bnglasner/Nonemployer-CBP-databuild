# Ben Glasner
# County level Nonemployer data with CBSA Uber treatment
# 7/16/2019

##########################
#         Set Up         #  
##########################

library(dplyr)
library(readstata13)
library(eeptools)
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
path_nes <- paste0(path_project,"\\EIG\\Noncompete\\Data\\Nonemployer Data")

setwd(path_nes)

# load in the NES county data 1997 - 2016
files <- list.files(pattern="Non-Employment data*")
myfiles <- lapply(files, read.dta13)

# Clean the data
for (i in 1:5) {
  myfiles[[i]] <- myfiles[[i]] %>% dplyr::select("st", "county", "naics", "estab","rcptot") 
  colnames(myfiles[[i]])[2] <- "cty" # Match column names
  myfiles[[i]]$YEAR.id <- 1996+i
}
for (i in 6:24) {
  myfiles[[i]] <- myfiles[[i]] %>% dplyr::select("st", "cty", "naics", "estab","rcptot") 
  myfiles[[i]]$YEAR.id <- 2001+(i-5)
}

# append NES data
NES <- do.call(rbind, myfiles)
rm(myfiles) # clear out everything other than NES

NES$estab[NES$estab==0] <- NA # assume that all zeros that are censured are actually 2 nonemployers

inflation_adj <- c(1.5,1.47,1.44,1.39,1.36,
                   1.33,1.30,1.27,1.23,1.19,
                   1.16,1.11,1.12,1.10,1.07,
                   1.05,1.03,1.01,1.01,1,
                   .98,.96,.94,.93)
YEAR.id <-c(1997,1998,1999,2000,2001,
            2002,2003,2004,2005,2006,
            2007,2008,2009,2010,2011,
            2012,2013,2014,2015,2016,
            2017,2018,2019,2020)



inflation_adj_df <- as.data.frame(cbind(inflation_adj,YEAR.id))

NES<- left_join(NES, inflation_adj_df)

NES$rcptot_inf <- NES$rcptot*NES$inflation_adj
# NES <- NES %>% filter(as.numeric(as.character(naics))<10000)
isid(NES, vars = c("st","cty","naics","YEAR.id"))

setwd(path_nes)

save(NES, file = "NES.RData")

