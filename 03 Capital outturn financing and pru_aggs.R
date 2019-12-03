# if intermediate outputs are enabled, load these outputs; else, stick with the outputs already in the environment
setwd(paste(project_folder, "Intermediate outputs", sep = ""))

ifelse(write_out_y_n == "y", financing_pru <- read.csv("02 Capital outturn financing and pru_standardise.csv"), "")

financing_pru <- financing_pru %>%
	gather(Year, value, 6:ncol(financing_pru)) %>%
	mutate(Year = gsub("X", "", Year))  %>%
	mutate(Year = gsub("[.]", "-", Year)) %>% 
	filter(!is.na(value))

# -------------------------------------------------------------------------------- apply adjustments
# add england total
# isolate grossing adjustment
# isolate GLA

England_published_total <- financing_pru %>% filter(LA == "England") %>% rename(England_published_total = value) %>% select(-LA)
grossing_adjustment <- financing_pru %>% filter(LA == "England (grossed)") %>% rename(England_grossed = value) %>% select(-LA)
GLA_adjustment <- financing_pru %>% filter(LA == "England (grossed, with GLA adjustment)") %>% rename(England_grossed_GLA = value) %>% select(-LA)

# Add England totals - remove any existing aggregate measures, and sum the remaining individual authorities
England_sum <- financing_pru %>%
	filter(!LA %in% c("England (grossed* excluding double counting**)", "England (grossed*)", "England (grossed)", "England (adjusted)", "England", "England (grossed, with GLA adjustment)")) %>%
	group_by(data_set, Variable_type, Variable, Year, Units) %>%
	transmute(LA_sum = as.numeric(value)) %>%
	summarise(LA_sum = sum(LA_sum, na.rm = TRUE))

# isolate differences
England_adjustments <- England_sum %>%
	left_join(England_published_total) %>% # these should be the same, except 1718 when CLG didn't give a raw Eng total
	mutate(summing_adjustment = round(England_published_total - LA_sum, 3)) %>%

	left_join(grossing_adjustment) %>%
	mutate(grossing_adjustment = round(England_grossed - LA_sum, 3)) %>%

	left_join(GLA_adjustment) %>%
	mutate(GLA_adjustment = round(England_grossed_GLA - England_grossed, 3)) %>%

	gather(LA, value, 6:12) %>%
	filter(!is.na(value)) %>%

	filter(!(LA == "summing_adjustment" & value == 0.000)) %>%
	filter(!(LA == "grossing_adjustment" & value == 0.000)) %>%
	filter(!(LA == "GLA_adjustment" & value == 0.000))

rm(England_sum, England_published_total, grossing_adjustment, GLA_adjustment)

# Assemble an England_best series with any available adjustments
#			1011	1112	1213	1314	1415	1516	1617	1718	1819		1718e	1819e	1920e
# England	x		x		x		x		x										x				
# grossed											x		x													
# GLA																x		x				x		x	
#			England	England	England	England	England	Grossed	Grossed	GLA		GLA		England	GLA	GLA

England_best <- bind_rows(
	filter(financing_pru, LA == "England" & Year %in% c("2004-05", "2005-06", "2006-07", "2007-08", "2008-09", "2009-10", "2010-11", "2011-12", "2012-13", "2013-14", "2014-15", "2017-18e")),
	filter(financing_pru, LA == "England" & data_set == "Prudential" & Year == "2018-19e"),
	filter(financing_pru, LA == "England (grossed)" & Year %in% c("2015-16", "2016-17")),
	filter(financing_pru, LA == "England (grossed, with GLA adjustment)")) %>%
	mutate(LA = "England_best")

England_adjustments <- England_adjustments %>%
	filter(LA %in% c("grossing_adjustment", "GLA_adjustment", "summing_adjustment"))

financing_pru <- bind_rows(
	filter(financing_pru, !LA %in% c("England (grossed* excluding double counting**)", "England (grossed*)", "England (grossed)", "England (adjusted)", "England", "England (grossed, with GLA adjustment)")),
	England_adjustments,
	England_best)

rm(England_adjustments, England_best)

# -------------------------------------------------------------------------------- build England 353
# create England_353 series of the 'normal' LAs
# this means drop police & fire, MCAs, GLA, City of London; keep the gross adjustment but drop the GLA adjustment

setwd(paste(project_folder, "Libraries", sep = ""))

LA_name_lookup <- read.csv("england_353_lib.csv") %>% 
	unique() %>% 
	`colnames<-` (c("continuity_LA_name", "class"))  # overrides any encoding glitches

financing_pru <- financing_pru %>% 
	left_join(LA_name_lookup, by = c("LA" = "continuity_LA_name")) %>%
	mutate(LA = as.factor(LA))

missing_match <- financing_pru %>% 
	select(LA, class) %>% 
	filter(is.na(class)) %>% 
	unique()

England_353 <- financing_pru %>% 
	filter(!class %in% c("Adjustment", "OTHER")) %>%
	group_by(data_set, Variable_type, Variable, Units, Year) %>%
	summarise(value = sum(value)) %>%
	mutate(LA = "England_353")

financing_pru <- bind_rows(financing_pru, England_353) %>% 
	select(-class) %>%
	mutate(LA = as.factor(LA))

rm(LA_name_lookup, England_353, missing_match)
# -------------------------------------------------------------------------------- add missing aggregates
financing_pru_wide <- spread(financing_pru, Year, value)

# mark basis
financing_pru <- bind_rows(
	filter(financing_pru, Year %in% c("2004-05", "2005-06", "2006-07", "2007-08", "2008-09", "2009-10", "2010-11", "2011-12", "2012-13", "2013-14", "2014-15", "2015-16", "2016-17", "2017-18", "2018-19")) %>%
	mutate(basis = "Outturn")
		,
	filter(financing_pru, Year %in% c("2017-18e", "2018-19e", "2019-20e")) %>%	mutate(basis = "Budget")) %>%
	mutate(Year = gsub("e", "", Year)
		)

#write out
setwd(output_folder)

# convert to a wide CSV (which takes less space than long)

financing_pru_wide <- spread(financing_pru, Year, value, fill = NA)

filter(financing_pru_wide, data_set == "Financing") %>% write.csv(file = "Capital financing outturn, 2004-05 to 2018-19.csv", row.names = FALSE, na = "")
filter(financing_pru_wide, data_set == "Prudential") %>% write.csv(file = "Prudential indicators, 2004-05 to 2018-19.csv", row.names = FALSE, na = "")

