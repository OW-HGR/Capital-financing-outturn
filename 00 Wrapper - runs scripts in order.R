t_0 <- Sys.time()
#	install the required libraries and their dependencies if they are not already in place 
if (!require(tidyverse)) install.packages('tidyverse', dependencies = TRUE)

# load libraries
library("tidyverse")	# general data handling and graphing toolbox
library("lubridate")  # date handling
library("foreign")		# loads .CSVs
library("readxl")		  # to read xlsx and xls files
library("fs")			    # supports navigating filepaths
library("janitor")		# cleans inputs - sets var names to lowercase with no special characters; labels unnamed columns

options(scipen = 999)	# disable exponential notation

#	set global variables
HMT_project_folder <- "C:/Users/RHMTOWilliamson/OneDrive - TrIS/Capital-financing-outturn/"
Mac_15_project_folder <- "/Users/mbp15/Dropbox/git/Capital-financing-outturn/"
Mac_12_project_folder <- "/Users/oscarwilliamson/Dropbox/git/Capital-financing-outturn/"

project_folder <- Mac_15_project_folder

HMT_output_folder <- "C:/Users/RHMTOWilliamson/OneDrive - TrIS/Long-data-output/"
Mac_15_output_folder <- "/Users/mbp15/Dropbox/Output/"
Mac_12_output_folder <- "/Users/oscarwilliamson/Dropbox/Dropbox/Output/"

output_folder <- Mac_15_output_folder
	
#	decide if you want each script to write out intermediate outputs and drop the tables, or just keep them loaded in the environment
write_out_y_n <- "n"

#	run scripts. tell it to return to the project folder after each one so it can find the next script
setwd(project_folder)
source("01 read data from xlsx.R")

setwd(project_folder)
source("02 standardise entities and vars.R")

setwd(project_folder)
source("03 Capital outturn financing and pru_aggs.R")


Sys.time() - t_0