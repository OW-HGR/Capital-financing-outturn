# if intermediate outputs are enabled, load these outputs; else, stick with the outputs already in the environment
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

ifelse(write_out_y_n == "y", financing_pru <- read.csv("01 Capital outturn financing and pru_stack.csv"), "")

financing_pru <- financing_pru %>%
	gather(Year, value, 4:ncol(financing_pru)) %>% 
	filter(!is.na(value)) %>%
	mutate(
		Year = gsub("X", "", Year),
		Year = gsub("[.]", "-", Year)) %>%
	filter(Year != "2003-04") # categories are very different in 03/04 - maybe come back to this one

# -------------------------------------------------------------------------------- Standardise vars
setwd(paste(project_folder, "Libraries", sep = ""))

fin_pru_lib <- read.csv("financing_pru_var_lib v2.csv") %>%
	select(-Year) %>% unique()

financing_pru <- left_join(financing_pru, fin_pru_lib)

missing_var <- financing_pru %>% select(original_variable, continuity_variable, Year) %>%
	filter(is.na(continuity_variable)) %>%
	unique()

# -------------------------------------------  write error logs for any undefined values
setwd(paste(project_folder, "Logs", sep = ""))

write.csv(missing_var, file = "missing_var.csv", row.names = FALSE)

rm(fin_pru_lib, missing_var)

financing_pru <- financing_pru %>% 
	filter(!continuity_variable %in% c("memo", "drop")) %>%
	filter(!cat_1 %in% c("memo", "drop"))

# -------------------------------------------------------------------------------- Standardise LA names
setwd(paste(project_folder, "Libraries", sep = ""))

LA_name_lookup <- read.csv("la_names_lookup.csv") %>% unique() %>% 
	`colnames<-` (c("original_LA_name", "continuity_LA_name")) 

financing_pru %<>%
	rename(original_LA_name = LA) %>% 
	left_join(LA_name_lookup)
rm(LA_name_lookup)

#write out missing LA names
missing_LA <- financing_pru %>%
	select(original_LA_name, Year, continuity_LA_name) %>%
	filter(is.na(continuity_LA_name)) %>% 
	unique()

setwd(paste(project_folder, "Logs", sep = ""))

write.csv(missing_LA, file = "missing_LA_name.csv", row.names = FALSE)
rm(missing_LA)

# tidy up
financing_pru <- financing_pru %>% 
	filter(continuity_LA_name != "drop") %>% 
	select(continuity_LA_name, cat_1, cat_2, continuity_variable, Year, Units, value) %>%
	rename(LA = continuity_LA_name, data_set = cat_1, Variable_type = cat_2, Variable = continuity_variable, Value = value)

#write out
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

financing_pru <- financing_pru %>% spread(Year, Value, fill = NA)

ifelse(write_out_y_n == "y", write.csv(financing_pru, file = "02 Capital outturn financing and pru_standardise.csv", row.names = FALSE), "")

