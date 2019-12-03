t_0 <- Sys.time()
#	install the required libraries and their dependencies if they are not already in place 
if (!require(tidyverse)) install.packages('tidyverse', dependencies = TRUE)

# load libraries
library(foreign)		# loads .CSVs
library("tidyverse")	# general data handling and graphing toolbox
options(scipen = 999)	# disable exponential notation
library(janitor)		# cleans inputs - sets var names to lowercase with no special characters; labels unnamed columns

#	set global variables
HMT_project_folder <- "C:/Users/RHMTOWilliamson/OneDrive - TrIS/Capital-financing-outturn/"
Mac_15_project_folder <- "/Users/mbp15/Dropbox/git/Capital-financing-outturn/"

project_folder <- Mac_15_project_folder

HMT_output_folder <- "C:/Users/RHMTOWilliamson/OneDrive - TrIS/Long-data-output/"
Mac_15_output_folder <- "/Users/mbp15/Dropbox/Output/"

output_folder <- Mac_15_output_folder
	
#	decide if you want each script to write out intermediate outputs and drop the tables, or just keep them loaded in the environment
write_out_y_n <- "n"

#	run scripts. tell it to return to the project folder after each one so it can find the next script
setwd(project_folder)
source("01 Capital outturn financing and pru_stack.R")

setwd(project_folder)
source("02 Capital outturn financing and pru_standardise.R")

setwd(project_folder)
source("03 Capital outturn financing and pru_aggs.R")


Sys.time() - t_0