# if intermediate outputs are enabled, load these outputs; else, stick with the outputs already in the environment

financing_pru <- bind_rows(financing_pru_before_1718, financing_pru_since_1718) %>% 
	mutate(la_name = as.factor(la_name), variable = as.factor(variable), year = as.factor(year), source = as.factor(source), tab = as.factor(tab), units = as.factor(units), basis = as.factor(basis)) %>%
	filter(!year %in% c("2000-01", "2001-02", "2002-03", "2003-04")) %>% # categories are very different before 2004-05 - maybe come back to this one
	rename(source_publication = source,
			 original_LA_name = la_name,
			 original_variable = variable)

financing_pru_wide <- financing_pru %>%
	select(-c(source_publication, tab, published, basis)) %>%
	spread(year, value)

# -------------------------------------------------------------------------------- Standardise vars
setwd(paste(project_folder, "Libraries", sep = ""))

fin_pru_lib <- read.csv("var lookup v2.csv")

financing_pru <- left_join(financing_pru, fin_pru_lib)

missing_var <- financing_pru %>% 
	filter(is.na(continuity_variable)) %>%
	select(original_variable) %>%
	distinct()

# write error logs for any undefined variables
setwd(paste(project_folder, "Logs", sep = ""))
write.csv(missing_var, file = "missing_var.csv", row.names = FALSE)

rm(fin_pru_lib, missing_var)

financing_pru_wide <- financing_pru %>%
	select(-c(original_variable, source_publication, tab, published, basis)) %>%
#	filter(original_LA_name == "Leeds" & continuity_variable == "Authorised limit" & category_1 == "Year end") %>%
	spread(year, value)

financing_pru <- financing_pru %>% 
	filter(!continuity_variable %in% c("memo", "drop")) %>%
	filter(!cat_1 %in% c("memo", "drop"))

# -------------------------------------------------------------------------------- Standardise LA names
setwd(paste(project_folder, "Libraries", sep = ""))

LA_name_lookup <- read.csv("la_names_lookup.csv") %>% distinct() %>% 
	`colnames<-` (c("original_LA_name", "continuity_LA_name")) 

financing_pru <- financing_pru %>% 
	left_join(LA_name_lookup)

rm(LA_name_lookup)

# -------------------------------------------  write error logs for any undefined LA names
missing_LA <- financing_pru %>%
	select(original_LA_name, year, continuity_LA_name) %>%
	filter(is.na(continuity_LA_name)) %>% 
	select(-year) %>%
	distinct()

setwd(paste(project_folder, "Logs", sep = ""))

write.csv(missing_LA, file = "missing_LA_name.csv", row.names = FALSE)
rm(missing_LA)

financing_pru <- financing_pru %>% 
	filter(!continuity_LA_name %in% c("CHECK", "drop")) # the LA that appears here as `CHECK` is a single, unlabelled, white-font value that appears in the publication

# -------------------------------------------------------------------------------- tidy up the table
financing_pru <- financing_pru %>%
	select(continuity_LA_name, cat_1, cat_2, continuity_variable, year, Units, value, source_publication, tab, published) %>%
	rename(LA = continuity_LA_name, 
				 Variable_type = cat_1, 
				 Data_coverage = cat_2, 
				 Variable = continuity_variable, 
				 Value = value)

#write out
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

financing_pru_wide <- financing_pru %>% 
	spread(year, Value, fill = NA)

ifelse(write_out_y_n == "y", write.csv(financing_pru, file = "02 Capital outturn financing and pru_standardise.csv", row.names = FALSE), "")

