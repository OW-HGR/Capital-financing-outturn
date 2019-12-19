## Summary of the approach
This workflow loads data that is published across different documents, consolidates it into a single table, and irons out any differences in layout and coding between publications. It is written to be easy to extend it by adding new releases as they are published.

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

2. the second part from around line 65 to line 100 strings together another UDF `read()` and a couple of dplyr functions to clean each table. The data is read in from the required tab, the column names are assigned from whichever row they are in in the original table, and any unwanted rows from the top of the sheet are dropped. The table is then converted to long-format <see [here](https://en.wikipedia.org/wiki/Wide_and_narrow_data)>.

. The identification of the row with the column names was done manually because we want to be extra sure that we've got the right value. 40 tabs are used as of Q2 2019-20.

The data is originally published in a wide format: a row for each LA, a column for each variable, and a value at the intersection of each. This script converts these to a long format, where there is only one value per row, with the metadata given as columns. More on the difference between wide data and long data 

The 40 long tables are then labelled with the coverage date and the name of the original spreadsheet and tab, stacked into one table, tidied up to remove unwanted columns and rows, and formatted to set the data types of the vectors to numerics and factors.

Because tabs are loaded by index number rather than name, and dates are added manually, there is a risk that the wrong date is applied. There is a check built in here that write a table showing the date and tab name. Just check that they are aligned. 

### Step 2: fix errors
This second module `02 fix errors.R` fixes a few errors that have been identified in the data. These are:
1. Forest of Dean appears twice in 2008-09. This step drops the duplicates.
2. From Q4 2018-19 to Q2 2019-20 inclusive there are entries for both `Essex Police, Fire and Crime Commissioner Fire and Rescue Authority` and `Essex Police, Fire and Crime Commissioner Police Authority`. They seem to be the same organisation. All the values for the second one are 0. To fix this, all reference to the second one are filtered out. The reason this is done by explicit filtering here rather than re-coding the organisation name to `drop` in the lookup table is as a precation in case the organisation name is used for non-zero values in the future. 
3. In Q3 2016-17, short-term inter-authority borrowing is incorrectly labelled as long-term, and the values for long-term inter-authority lending are missing. This is addressed by fixing the labelling error and setting NAs for long-term borrowing.

### Step 3: standardise coding of entities and variables
The third module `03 standardise vars and entities.R` deals with the issue of stylistic variation between releases. 

LA names are addressed first. A lookup table is loaded that contains all the variations of the names of LAs that was found in previous releases of the debt and investment series, and their standardised form. This lookup is included in this repo, in the `Libraries` folder. Here is a sample to illustrate the issue:

|`original_LA_name`|`continuity_LA_name`|
|---|---|
|Brighton and Hove|Brighton & Hove|
|Brighton & Hove|Brighton & Hove|
|Brighton & Hove UA|Brighton & Hove|

This lookup is merged into the long table produced in module one. An error log is produced for any LA names that are in the data but missing from the lookup table, and written out to the `Logs` folder in the working directory that you have set in `00 Wrapper`. If an undefined value is written out, just paste it onto the end of the `original_LA_name` column in the lookup table, and provide a corresponding value for the `continuity_LA_name` column. This processes is based on names rather than ecode because not all datasets contain an ecode, and because a mis-labelled ecode is more likely to go unnoticed. 

The same process is then run for the variable, which in this case is the lender (for debt) or the type of investment. 

The data includes totals for the UK and for E/S/W/NI. This section then checks that these add up correctly and writes a table of any discrepancies. Discrepancies under 1% are probably rounding.

You now have a single table 353,532 rows, each with a single observation and seven variables:
1. LA name
2. whether the data is from the debt series or the investment series
3. the counterparty (UK banks, PWLB etc)
4. whether the debt is long term or short term
5. the date of the observation
6. the units (£ms)
7. the filename of the source publication

As a last step, the table is written out to the output folder you have set in `00 Wrapper`, and error logs are printed in the environment. If the script is working correctly there will be no entries in the error logs for `missing_LA` or `missing_counterparty` and no difference between the UK total and the sum of England, Scotland, Wales, and NI. There are 26 undercounts between the sum of individual LAs and the UK totals, but these are so small as to conceivably be rounding error.

### Licence
Unless stated otherwise, the codebase is released under [the MIT License](https://github.com/OW-HGR/Debt-and-investment-quarterly/blob/master/LICENCE.txt). This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright](https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government 3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
