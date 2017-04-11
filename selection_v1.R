# SELECTION

# GOAL: Look at recruitment. See who is applying to a corp, and how corps advertise.


library(RODBC);
library(ggplot2);
library(lubridate);
library(plyr);
library(scales);
library(data.table)
require(dplyr)


# Corp History 
conn <- odbcDriverConnect('DRIVER={SQL Server};SERVER=researchdb;DATABASE=ebs_RESEARCH;Trusted Connection=true;Integrated Security=true;')
cph = data.table(sqlQuery(conn,"Select TOP 100 * FROM ebs_FACTORY.eve.corporationHistory"))

cph %>% colnames(.)


# Potential proxy here for "battle field" stressors
bsl = c(43:52,83:106) # Damage from, Combat Deaths
colnames(cph)[bsl]

# 
