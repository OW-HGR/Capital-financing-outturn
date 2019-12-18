# read straight from the published source, as with the borrowing and investment series

library("readxl")		
library("fs")			# cross-platform, uniform interface to file system operations

# -------------------------------------------------------------------------------- load data
# original file names have been preserved other than where they are missing a date, in which case it is added at the end
setwd(paste(project_folder, "Source data", sep = ""))

COR_1819 <- "COR_2018-19_outputs_COR_B.xlsx"
COR_1718 <- "FINAL_COR_B 1718.xlsx" 
COR_1617 <- "COR4_Total_capital_expenditure___receipts_Financing___Prudential_information 1617.xlsx"
COR_1516 <- "LA_drop-down_capital_expenditure_receipts_and_financing_COR4_2015-16.xls"
COR_1415 <- "LA_drop-down_capital_expenditure_receipts_and_financing_COR4_2014-15.xls"
COR_1314 <- "LA_drop-down_capital_expenditure_receipts_and_financing_COR4_2013-14.xls"
COR_1213 <- "LA_drop-down_capital_expenditure_receipts_and_financing_COR4_2012-13.xls"
COR_1112 <- "LA_drop-down_capital_expenditure_receipts__financing_COR4_2011-12.xls"
COR_1011 <- "2016372.xls"
COR_0910 <- "1821128.xls"
COR_0809 <- "1719274.xls"
COR_0708 <- "Capital_Outturn_Return__COR4__2007-08_data.xls"
COR_0607 <- "LA drop-down capital expenditure receipts & financing COR4 2006-07.xls"
COR_0506 <- "LA drop-down capital expenditure receipts & financing COR4 2005-06.xls"
COR_0405 <- "LA drop-down capital expenditure receipts & financing COR4 2004-05.xls"
COR_0304 <- "LA drop-down capital expenditure receipts & financing COR4 2003-04.xls"
COR_0203 <- "LA drop-down capital expenditure receipts & financing COR4 2002-03.xls"
COR_0102 <- "LA drop-down capital expenditure receipts & financing COR4 2001-02.xls"
COR_0001 <- "LA drop-down capital expenditure receipts & financing COR4 2000-01.xls"

# a function to get the names of the tabs of the source spreadsheets
tab_names <- function(source_table) {
	excel_sheets(source_table) %>%
		data.frame() %>%
		rename(tabs = ".") %>%
		mutate(tabs = as.character(tabs))
}

tabs_1819 <- tab_names(COR_1819)
tabs_1718 <- tab_names(COR_1718)
tabs_1617 <- tab_names(COR_1617)
tabs_1516 <- tab_names(COR_1516)
tabs_1415 <- tab_names(COR_1415)
tabs_1314 <- tab_names(COR_1314)
tabs_1213 <- tab_names(COR_1213)
tabs_1112 <- tab_names(COR_1112)
tabs_1011 <- tab_names(COR_1011)
tabs_0910 <- tab_names(COR_0910)
tabs_0809 <- tab_names(COR_0809)
tabs_0708 <- tab_names(COR_0708)
tabs_0607 <- tab_names(COR_0607)
tabs_0506 <- tab_names(COR_0506)
tabs_0405 <- tab_names(COR_0405)
tabs_0304 <- tab_names(COR_0304)
tabs_0203 <- tab_names(COR_0203)
tabs_0102 <- tab_names(COR_0102)
tabs_0001 <- tab_names(COR_0001)

# a function to read in a tab and tidy it up
read <- function(sheet_name, tab_number, col_name_row_num, drop_depth) {
	read_excel(sheet_name, tab_number) %>% 															# specify the sheet to load from, and which number tab to read
		`colnames<-`(c(slice(read_excel(sheet_name, tab_number), col_name_row_num))) %>% 	# identify the row with the column names, and apply them to the columns
		clean_names() %>% 																									# set varnames to lower case, remove special characters, unique-ify duplicate names
		slice(-1:drop_depth)																								# drop unwanted top rows, to a depth of x from the top
}

# load each tab, convert to long-format, label
fin_1819 <- read(COR_1819, 5, 4, -4) %>% gather(var, value, 6:25) %>% mutate(Year = "2018-19", source = COR_1819, tab = tabs_1819[5,], published = "26 September 2019")
fin_1718 <- read(COR_1718, 4, 4, -5) %>% gather(var, value, 6:28) %>% mutate(Year = "2017-18", source = COR_1718, tab = tabs_1718[4,], published = "11 October 2018")
fin_1617 <- read(COR_1617, 5, 6, -6) %>% gather(var, value, 5:49) %>% mutate(Year = "2016-17", source = COR_1617, tab = tabs_1617[5,], published = "28 September 2017")
fin_1516 <- read(COR_1516, 4, 1, -1) %>% gather(var, value, 5:47) %>% mutate(Year = "2015-16", source = COR_1516, tab = tabs_1516[4,], published = "15 September 2016")
fin_1415 <- read(COR_1415, 4, 1, -1) %>% gather(var, value, 4:42) %>% mutate(Year = "2014-15", source = COR_1415, tab = tabs_1415[4,], published = "7 October 2015") %>% rename(la_name = na_2)
fin_1314 <- read(COR_1314, 4, 1, -1) %>% gather(var, value, 4:53) %>% mutate(Year = "2013-14", source = COR_1314, tab = tabs_1314[4,], published = "26 March 2015") %>% rename(la_name = na_2)
fin_1213 <- read(COR_1213, 4, 1, -5) %>% gather(var, value, 4:53) %>% mutate(Year = "2012-13", source = COR_1213, tab = tabs_1213[4,], published = "17 October 2013") %>% rename(la_name = na_2)
fin_1112 <- read(COR_1112, 4, 1, -1) %>% gather(var, value, 5:57) %>% mutate(Year = "2011-12", source = COR_1112, tab = tabs_1112[4,], published = "14 February 2013")
fin_1011 <- read(COR_1011, 4, 1, -1) %>% gather(var, value, 5:54) %>% mutate(Year = "2010-11", source = COR_1011, tab = tabs_1011[4,], published = "26 October 2011")
fin_0910 <- read(COR_0910, 5, 2, -2) %>% gather(var, value, 5:54) %>% mutate(Year = "2009-10", source = COR_0910, tab = tabs_0910[5,], published = "28 October 2010")
fin_0809 <- read(COR_0809, 4, 1, -2) %>% gather(var, value, 5:54) %>% mutate(Year = "2008-09", source = COR_0809, tab = tabs_0809[4,], published = "8 April 2010") %>% rename(la_name = na_2)
fin_0708 <- read(COR_0708, 4, 1, -2) %>% gather(var, value, 5:55) %>% mutate(Year = "2007-08", source = COR_0708, tab = tabs_0708[4,], published = "31 December 2008") %>% rename(la_name = na_2)
fin_0607 <- read(COR_0607, 4, 2, -2) %>% gather(var, value, 5:55) %>% mutate(Year = "2006-07", source = COR_0607, tab = tabs_0607[4,], published = "Published 1 August 2013")
fin_0506 <- read(COR_0506, 4, 2, -2) %>% gather(var, value, 5:53) %>% mutate(Year = "2005-06", source = COR_0506, tab = tabs_0506[4,], published = "Published 1 August 2013")
fin_0405 <- read(COR_0405, 4, 2, -2) %>% gather(var, value, 5:55) %>% mutate(Year = "2004-05", source = COR_0405, tab = tabs_0405[4,], published = "Published 1 August 2013")
fin_0304 <- read(COR_0304, 4, 1, -1) %>% gather(var, value, 5:57) %>% mutate(Year = "2003-04", source = COR_0304, tab = tabs_0304[4,], published = "Published 1 August 2013")
fin_0203 <- read(COR_0203, 4, 1, -2) %>% gather(var, value, 5:57) %>% mutate(Year = "2002-03", source = COR_0203, tab = tabs_0203[4,], published = "Published 1 August 2013")
fin_0102 <- read(COR_0102, 4, 1, -1) %>% gather(var, value, 5:56) %>% mutate(Year = "2001-02", source = COR_0102, tab = tabs_0102[4,], published = "Published 1 August 2013")
fin_0001 <- read(COR_0001, 4, 1, -2) %>% gather(var, value, 5:57) %>% mutate(Year = "2000-01", source = COR_0001, tab = tabs_0001[4,], published = "Published 1 August 2013")

# GLA appears twice in 1718 and 1819 - once as an LA and once as a category. drop the second one to avoid double counting
fin_1819 <- fin_1819 %>% filter(class != "GLA")
fin_1718 <- fin_1718 %>% filter(class != "GLAG")

financing_pru <- bind_rows(fin_1819, fin_1718, fin_1617, fin_1516, fin_1415, fin_1314, fin_1213, fin_1112, fin_1011, fin_0910, fin_0809, fin_0708, fin_0607, fin_0506, fin_0405, fin_0304, fin_0203, fin_0102, fin_0001) %>% 
	select(-c(lgf_code, ons_code, ecode, class, subclass, region, na, na_3, na_4)) %>%
	rename(source_publication = source,
				 original_LA_name = la_name,
				 original_variable = var) %>%
	mutate(original_LA_name = as.factor(original_LA_name),
				 original_variable = as.factor(original_variable),
				 value = as.numeric(value),
				 value = value/ 1000,
				 Units = "GBPmillion",
				 Year = as.factor(Year),
				 source_publication = as.factor(source_publication),
				 tab = as.factor(tab),
				 published = as.factor(published)) %>%
	filter(!is.na(value))
				 
rm(fin_1819, fin_1718, fin_1617, fin_1516, fin_1415, fin_1314, fin_1213, fin_1112, fin_1011, fin_0910, fin_0809, fin_0708, fin_0607, fin_0506, fin_0405, fin_0304, fin_0203, fin_0102, fin_0001)
rm(tabs_1819, tabs_1718, tabs_1617, tabs_1516, tabs_1415, tabs_1314, tabs_1213, tabs_1112, tabs_1011, tabs_0910, tabs_0809, tabs_0708, tabs_0607, tabs_0506, tabs_0405, tabs_0304, tabs_0203, tabs_0102, tabs_0001)

financing_pru_wide <- financing_pru %>% select(-c(source_publication, tab, published)) %>% spread(Year, value)

# write out
setwd(paste(project_folder, "Intermediate outputs", sep = ""))
ifelse(write_out_y_n == "y", write.csv(financing_pru, file = "01 Capital outturn financing and pru_stack.csv", row.names = FALSE), "")

