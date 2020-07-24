# -------------------------------------------------------------------------------- load data
# original file names have been preserved in the folder, other than where they are missing a date, in which case it is added at the end
setwd(paste(project_folder, "Source data", sep = ""))
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
	read_excel(sheet_name, tab_number) %>% 	# specify the sheet to load from, and which number tab to read
	`colnames<-`(c(slice(read_excel(sheet_name, tab_number), col_name_row_num))) %>% 	# identify the row with the column names, and apply them to the columns
	clean_names() %>% 											# set varnames to lower case, remove special characters, unique-ify duplicate names
	slice(-1:drop_depth)										# drop unwanted top rows, to a depth of x from the top
}

fin_1617 <- read(COR_1617, 5, 6, -6) %>% gather(variable,value, 5:49) %>% mutate(year = "2016-17", source = COR_1617, tab = tabs_1617[5,], published = ymd("2017-09-28"))
fin_1516 <- read(COR_1516, 4, 1, -1) %>% gather(variable,value, 5:47) %>% mutate(year = "2015-16", source = COR_1516, tab = tabs_1516[4,], published = ymd("2016-09-15"))
fin_1415 <- read(COR_1415, 4, 1, -1) %>% gather(variable,value, 4:42) %>% mutate(year = "2014-15", source = COR_1415, tab = tabs_1415[4,], published = ymd("2015-10-07")) %>% rename(la_name = na_2)
fin_1314 <- read(COR_1314, 4, 1, -1) %>% gather(variable,value, 4:53) %>% mutate(year = "2013-14", source = COR_1314, tab = tabs_1314[4,], published = ymd("2015-03-26")) %>% rename(la_name = na_2)
fin_1213 <- read(COR_1213, 4, 1, -5) %>% gather(variable,value, 4:53) %>% mutate(year = "2012-13", source = COR_1213, tab = tabs_1213[4,], published = ymd("2013-10-17")) %>% rename(la_name = na_2)
fin_1112 <- read(COR_1112, 4, 1, -1) %>% gather(variable,value, 5:57) %>% mutate(year = "2011-12", source = COR_1112, tab = tabs_1112[4,], published = ymd("2013-02-14"))
fin_1011 <- read(COR_1011, 4, 1, -1) %>% gather(variable,value, 5:54) %>% mutate(year = "2010-11", source = COR_1011, tab = tabs_1011[4,], published = ymd("2011-10-26"))
fin_0910 <- read(COR_0910, 5, 2, -2) %>% gather(variable,value, 5:54) %>% mutate(year = "2009-10", source = COR_0910, tab = tabs_0910[5,], published = ymd("2010-10-28"))
fin_0809 <- read(COR_0809, 4, 1, -2) %>% gather(variable,value, 5:54) %>% mutate(year = "2008-09", source = COR_0809, tab = tabs_0809[4,], published = ymd("2010-04-08")) %>% rename(la_name = na_2)
fin_0708 <- read(COR_0708, 4, 1, -2) %>% gather(variable,value, 5:55) %>% mutate(year = "2007-08", source = COR_0708, tab = tabs_0708[4,], published = ymd("2008-12-31")) %>% rename(la_name = na_2)
fin_0607 <- read(COR_0607, 4, 2, -2) %>% gather(variable,value, 5:55) %>% mutate(year = "2006-07", source = COR_0607, tab = tabs_0607[4,], published = ymd("2013-08-01"))
fin_0506 <- read(COR_0506, 4, 2, -2) %>% gather(variable,value, 5:53) %>% mutate(year = "2005-06", source = COR_0506, tab = tabs_0506[4,], published = ymd("2013-08-01"))
fin_0405 <- read(COR_0405, 4, 2, -2) %>% gather(variable,value, 5:55) %>% mutate(year = "2004-05", source = COR_0405, tab = tabs_0405[4,], published = ymd("2013-08-01"))
fin_0304 <- read(COR_0304, 4, 1, -1) %>% gather(variable,value, 5:57) %>% mutate(year = "2003-04", source = COR_0304, tab = tabs_0304[4,], published = ymd("2013-08-01"))
fin_0203 <- read(COR_0203, 4, 1, -2) %>% gather(variable,value, 5:57) %>% mutate(year = "2002-03", source = COR_0203, tab = tabs_0203[4,], published = ymd("2013-08-01"))
fin_0102 <- read(COR_0102, 4, 1, -1) %>% gather(variable,value, 5:56) %>% mutate(year = "2001-02", source = COR_0102, tab = tabs_0102[4,], published = ymd("2013-08-01"))
fin_0001 <- read(COR_0001, 4, 1, -2) %>% gather(variable,value, 5:57) %>% mutate(year = "2000-01", source = COR_0001, tab = tabs_0001[4,], published = ymd("2013-08-01"))


financing_pru_before_1718 <- bind_rows(fin_1617, fin_1516, fin_1415, fin_1314, fin_1213, fin_1112, fin_1011, fin_0910, fin_0809, fin_0708, fin_0607, fin_0506, fin_0405, fin_0304, fin_0203, fin_0102, fin_0001) %>% 
	select(-c(ons_code, ecode, class, region, na, na_3, na_4)) %>%

	mutate(
				 value = as.numeric(value),
				 value = value/ 1000,
				 units = "GBPmillion",
				 basis = "Outturn") %>%
	filter(!is.na(value)) %>%
	filter(!is.na(la_name))
				 
rm(fin_1617, fin_1516, fin_1415, fin_1314, fin_1213, fin_1112, fin_1011, fin_0910, fin_0809, fin_0708, fin_0607, fin_0506, fin_0405, fin_0304, fin_0203, fin_0102, fin_0001)
rm(tabs_1617, tabs_1516, tabs_1415, tabs_1314, tabs_1213, tabs_1112, tabs_1011, tabs_0910, tabs_0809, tabs_0708, tabs_0607, tabs_0506, tabs_0405, tabs_0304, tabs_0203, tabs_0102, tabs_0001)

