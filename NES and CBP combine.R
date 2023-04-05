# Ben Glasner
# County level Nonemployer data with CBP Data
# 7/16/2019

##########################
#         Set Up         #  
##########################

library(dplyr)
library(eeptools)
library(readxl)
library(tidyr)

# https://github.com/keberwein/blscrapeR
library(blscrapeR)

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
# Path to saved cohort data 
path_cbp <- paste0(path_project,"\\EIG\\Noncompete\\Data\\CBP")


setwd(path_nes)
load("NES.RData")

setwd(path_cbp)
load("CBP_2000_2020.RData")

setwd(path_data)
Noncompete_leg_panel <- read_excel("Noncompete_leg_panel.xlsx")
load("county_info_census2000.RData")

df <- get_bls_county()

########################################
DFfilled <- Noncompete_leg_panel %>%
  complete(AREA, Year = full_seq(Year, 1)) %>%
  as.data.frame() 
DFfilled <- DFfilled %>% group_by(AREA) %>% 
  fill(AREA_TITLE, .direction = "down") %>% 
  fill(PRIM_STATE, .direction = "down") %>% 
  fill(Noncompete_leg_exemptions, .direction = "down") %>% 
  fill(Noncompete_ban, .direction = "down") %>% 
  dplyr::ungroup()
names(DFfilled)[1] <- "st"
names(DFfilled)[2] <- "years"

DFfilled$st <- as.numeric(as.character(DFfilled$st))
DFfilled$years <- as.numeric(as.character(DFfilled$years))

# DFfilled %>% 
#   panelview(X = "years", 
#             D = "Noncompete_leg", 
#             index = c("AREA_TITLE","years"),
#             pre.post = TRUE,
#             xlab = "Year",
#             ylab = "State",
#             main = "Treatment Status",
#             background = "white",
#             gridOff = FALSE) 

##########################################################

using <- left_join(NES,CBP)
rm(NES,CBP)
using <- using %>% mutate(four_digit_naics = if_else(between(as.numeric(naics),1000,9999),1,0),
                          three_digit_naics = if_else(between(as.numeric(naics),100,999),1,0),
                          two_digit_naics = if_else(between(as.numeric(naics),0,99),1,0),
                          years =as.numeric(as.character(YEAR.id)))

isid(using, vars = c("st","cty","naics","YEAR.id"))

##############################################################
using$st <- as.numeric(as.character(using$st))
using <- left_join(using,DFfilled)

using$Noncompete_leg <- 0 
using$Noncompete_leg[using$Noncompete_leg_exemptions==1 | using$Noncompete_ban==1] <- 1 

DFfilled$Noncompete_leg <- 0 
DFfilled$Noncompete_leg[DFfilled$Noncompete_leg_exemptions==1 | DFfilled$Noncompete_ban==1] <- 1 

states <- using %>% group_by(st) %>% summarise(ever_noncompete = max(Noncompete_leg))
using <- left_join(using,states)
##############################################################
labor_force_sum <- sum(df$labor_force)
df <- df %>% mutate(st = as.numeric(as.character(fips_state)),
                    cty = as.numeric(as.character(fips_county)),
                    share_lf = labor_force/labor_force_sum)


using <- left_join(using,df)
using  <- inner_join(using,census)
save(using, file = "NES_CBP_2000_2020.RData")
