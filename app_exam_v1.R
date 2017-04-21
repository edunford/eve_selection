

# GOAL: Look at the distribution of applications/invitations within the relevant corporations

require(revemetrics)
require(tidyverse)



corps = "select distinct corporationID from edvald_research.umd.crpSampSelection" %>% QueryDB()
head(corps)

set.seed(321)
# Draw a random sample
draw = corps %>% sample_n(5) %>% unlist(use.names = F) %>% paste(.,collapse=", ")
record <- "select * from edvald_research.umd.corporationApps
where corporationID in (@{corps})" %>% QueryDB(sql.params = list(corps=draw) )

record %>% mutate(applied = as.numeric(status==0),
                  invited = as.numeric(status==8)) %>% 
  arrange(eventDate,corporationID) %>% select(-status)
head(record)
