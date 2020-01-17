## Summary of the approach
This workflow loads data that is published across different documents, consolidates it into a single table, and irons out any differences in layout and coding between publications. It is written to be easy to extend by adding new releases as they are published.

## Applying the approach to data
The approach can be applied to lots of different publications. Here, it is applied to the MCHLG series covering capital financing and prudential indicators for English LAs. 

### Step 0: set up the working environment
The workflow is broken up into thematic modules that should be run in order. To set up your working environment:
1. Clone this project to your computer.

2. Get the data. Data back to 2000-01 is available here on [on GOV.UK](https://www.gov.uk/government/collections/local-authority-capital-expenditure-receipts-and-financing). The publications used here are included in the repo. Each sheet contains a series of tabs. Each tab has a table with a row for each LA, and a column for each of the variables of interest. 

3. Open the script called `00 Wrapper` and set your file path for your project folder and your output folder. You can also toggle the option to write out the latest working table at the end of each module. This is switched off by default but can be useful for debugging.

If you then run `00 Wrapper` it will work load the required libraries, run through each module in order, and save the output in the specified folder.

### Step 1: load and clean the data
The module `01 read data from xlsx.R` can be thought of in three parts:
1. the first part, to around line 60, locates the data within the project folder and assigns the routing information to R objects that can be called later. The full file name of each publication is assigned to a shorter code (eg `COR4_Total_capital_expenditure___receipts_Financing___Prudential_information 1617.xlsx` becomes `COR_1617`), and the tab labels of each publication are read in as a string, using a UDF `tab_names`.

2. the second part from around line 65 to line 100 strings together another UDF `read()` and a couple of dplyr functions to clean each table. The data is read in from the required tab, the column names are assigned from whichever row they are in in the original table, and any unwanted rows from the top of the sheet are dropped. The table is then converted to long-format (see [here](https://en.wikipedia.org/wiki/Wide_and_narrow_data)). A column is added with the year, and then the metadata of the original publication is added to the end: a column each for file name, tab, and publication date. These three or four steps are done on a single line for each object as the code gets unwieldy if you split them over multiple lines.

3. the third part from line 100 to the end converts the tables into a single stack. There are some duplicates which are removed. Columns are renamed as required and vectors are formatted as numerics or factors as required. Finally, the table is converted from wide format, just to check that there are no duplicate rows. 

### Step 2: standardise coding of entities and variables
The second module `02 standardise vars and entities.R` deals with the issue of stylistic variation between releases. 

Variable names are addressed first. A lookup table is loaded that contains all the variations of the variables that were found in previous releases of the COR, and their standardised form. This lookup is included in this repo, in the `Libraries` folder. Here is a sample to illustrate the issue:

|`original_variable`|`continuity_variable`|
|---|---|
|capital_grants_and_contributions_from_private_developers|Developer contributions|
|grants_and_contributions_from_private_developers_and_from_leaseholders_etc|Developer contributions|
|grants_contributions_from_private_developers|Developer contributions|
|grants_from_private_developers_leaseholders_etc|Developer contributions|

This lookup was built by starting with the variables that appear in 2018-19, standardising these, and then working backwards one year at a time to pick up any variables that have not yet been picked up. This is recorded in the column `year last seen`. The aim of this is to make it easier to tell if a variable was discontinued or if it was just significantly renamed between releases - helpful for the variables about receipts, borrowing, and debt, which can be quite similar.

This lookup is merged into the long table produced in module one. An error log is produced for any variables that are in the data but missing from the lookup table, and written out to the `Logs` folder in the working directory that you have set in `00 Wrapper`. If an undefined value is written out, just paste it onto the end of the `original_variable` column in the lookup table, and provide a corresponding value for the `continuity_variable` column. 

The same process is then run for the LA names. It uses names rather than ecode because not all datasets contain an ecode, and because a mis-labelled ecode is more likely to go unnoticed. 

As at the end of module one, the table is converted from wide format, just to check that there are no duplicate rows. 

### 03 Apply adjustments and add aggregates
This section makes explicit the adjustments that are applied in the COR. The aggregates and adjustments that are included vary from year to year. They are:
1. An unadjusted total (`summing_adjustment`) supposedly made by summing the LAs. Sometimes this differs from the actual sum.
2. A grossing adjustment (`grossing_adjustment`) to add in an estimate of spending by LAs that didn't submit returns.
3. A London adjustment (`GLA_adjustment`) to strip out flows between the GLA and London Boroughs. 

These adjustments are isolated from the sum of LAs, and added in as if they were LAs called `summing_adjustment`, `grossing_adjustment` etc. These adjustments can then be combined with LA-level numbers as required.

It isn't straightforward to identify the England total across years from the COR, because several different England totals are given, with and without adjustments, and the coverage changes from year to year. This section adds an LA called `England_best`, which gives the best approximation of the England total from each year, based on the adjustments used at the time. It also gives a figure for the 353 'normal' English LAs, which excludes bodies that are categorised as OTHER in the ONS and MHCLG publications: police, fire, national parks, MCAs, and the City of London. This is called `England_353`. `England_best` or `England_353` are usually the best ones to use for country-level analysis.

You now have a single table with 243,198 rows, each with a single observation and nine variables:
1. LA name
2. `Data_coverage` - whether the dataset is financing, prudential, or one of the other bits that are included in some years
3. `Variable_type` which gives a further breakdown of `Data_coverage` 
4. variable
5. the year of the observation
6. the units (£ms)
7. the filename of the source publication
8. the tab of the source publication
9. the publication date of the source publication

As a last step, the table is written out to the output folder you have set in `00 Wrapper`.

### Licence
Unless stated otherwise, the codebase is released under [the MIT License](https://github.com/OW-HGR/Debt-and-investment-quarterly/blob/master/LICENCE.txt). This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright](https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government 3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
