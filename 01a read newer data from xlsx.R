# -------------------------------------------------------------------------------- load data
# original file names have been preserved in the folder, other than where they are missing a date, in which case it is added at the end
setwd(paste(project_folder, "Source data", sep = ""))

# budgets
COR_fin_2021 <- "CER_2020-21_B_financing.xlsx" # 2 July 2020
COR_pru_2021 <- "CER_2020-21_C_prudential_system_information.xlsx" # 2 July 2020

COR_fin_1920 <- "CER_2019-20_B.xlsx" # 31 January 2020
COR_pru_1920 <- "CER_2019-20_C.xlsx" # 31 January 2020

# outturn
COR_pru_1819 <- "COR_2018-19_outputs_COR_C.xlsx" # 26 September 2019
COR_fin_1819 <- "COR_2018-19_outputs_COR_B.xlsx" # 26 September 2019

COR_fin_1718 <- "FINAL_COR_B 1718.xlsx" # 11 October 2018
COR_pru_1718 <- "FINAL_COR_C 1718.xlsx" # 11 October 2018

# -------------------------------------------------------------------- 2020-21
fin_pru_2021 <- bind_rows(
		# financing
		read_excel(COR_fin_2021, 4) %>%
				clean_names() %>%
				slice(-1:-4) %>%
				slice(-446) %>% # remove double-count of GLA
				select(-c(la_lgf_code, la_ons_code, la_class_code, la_subclass_code)) %>%
				gather(variable, value, 2:22) %>%
				mutate(source = COR_fin_2021),
			
		# prudential
			read_excel(COR_pru_2021, 4) %>%
				clean_names() %>%
				slice(-1:-4) %>%
				slice(-445) %>% # remove double-count of GLA
				select(-c(la_lgf_code, la_ons_code, la_class_code, la_subclass_code)) %>%
				gather(variable, value, 2:25) %>%
				mutate(source = COR_pru_2021)) %>%
	
	mutate(
		year = "2020-21",
		published = ymd("2020-07-02"),
		basis = "Budget")

# -------------------------------------------------------------------- 2019-20
fin_pru_1920 <- bind_rows(
	# financing
		read_excel(COR_fin_1920, 4) %>%
			clean_names() %>%
			slice(-1:-4) %>%
			slice(-450) %>% # remove double-count of GLA
			select(-c(la_lgf_code, la_ons_code, la_class_code, la_subclass_code)) %>%
			gather(variable, value, 2:22) %>%
			mutate(source = COR_fin_1920),

	# prudential
		read_excel(COR_pru_1920, 4) %>%
			clean_names() %>%
			slice(-1:-4) %>%
			slice(-449) %>% # remove double-count of GLA
			select(-c(la_lgf_code, la_ons_code, la_class_code, la_subclass_code)) %>%
			gather(variable, value, 2:25) %>%
			mutate(source = COR_pru_1920)) %>%

	mutate(
		year = "2019-20",
		published = ymd("2019-01-31"),
		basis = "Budget")

# -------------------------------------------------------------------- 2018-19
fin_pru_1819 <- bind_rows(
		# financing
		read_excel(COR_fin_1819, 5) %>%
			clean_names() %>%
			slice(-1:-4) %>%
			slice(-456) %>% # remove double-count of GLA
			select(-c(la_lgf_code, la_ons_code, la_class_code, la_subclass_code)) %>%
			gather(variable, value, 2:21) %>%
			mutate(source = COR_fin_1819),
	
		# CFR
		read_excel(COR_pru_1819, 5) %>%
			clean_names() %>%
			slice(-1:-4) %>%
			slice(-456) %>% # remove double-count of GLA
			select(-c(la_lgf_code, la_ons_code, la_class_code, la_subclass_code)) %>%
			gather(variable, value, 2:11) %>%
			mutate(source = COR_pru_1819),

		# borrowing and lending
		read_excel(COR_pru_1819, 6) %>%
			clean_names() %>%
			slice(-1:-4) %>%
			slice(-456) %>% # remove double-count of GLA
			select(-c(la_lgf_code, la_ons_code, la_class_code, la_subclass_code)) %>%
			gather(variable, value, 2:20) %>%
			mutate(source = COR_pru_1819)) %>%
	
	mutate(
		year = "2018-19",
		published = ymd("2019-09-26"),
		basis = "Outturn")

# -------------------------------------------------------------------- 2017-18
fin_pru_1718 <- bind_rows(
		# financing
		read_excel(COR_fin_1718, 4) %>%
			clean_names() %>%
			slice(-1:-5) %>%
			slice(-457) %>% # remove double-count of GLA
			select(-c(x1, x2, x4, x5)) %>%
			gather(variable, value, 2:24) %>%
			mutate(source = COR_fin_1718),
		
		# prudential
		read_excel(COR_pru_1718, 4) %>%
			clean_names() %>%
			slice(-1:-4) %>%
			slice(-457) %>% # remove double-count of GLA
			select(-c(x1, x2, x4, x5)) %>%
			gather(variable, value, 2:30) %>%
			mutate(source = COR_pru_1718)) %>%
	
	mutate(
		year = "2017-18",
		published = ymd("2018-10-11"),
		basis = "Outturn") %>%
	rename(la_name = x3)

# --------------------------------------------------------------------  stack
financing_pru_since_1718 <- 
	bind_rows(fin_pru_1718, fin_pru_1819, fin_pru_1920, fin_pru_2021) %>%
	mutate(
		value = as.numeric(value), 
		value = value/1000,
		units = "GBPmillion") %>%
	filter(!is.na(value)) %>%
	mutate(
		variable = gsub("fin1_", "", variable),
		variable = gsub("pru1_", "", variable),
		variable = gsub("pru2t1_", "", variable),
		variable = gsub("pru2t2_", "", variable))

rm(fin_pru_1718, fin_pru_1819, fin_pru_1920, fin_pru_2021)



