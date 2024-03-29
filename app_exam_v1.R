

# GOAL: Look at the distribution of applications/invitations within the relevant corporations

require(revemetrics)
require(tidyverse)
require(lubridate)



corps = "select distinct corporationID from edvald_research.umd.crpSampSelection" %>% QueryDB()
head(corps)

set.seed(321)
# Draw a random sample
draw = corps %>% sample_n(5) %>% unlist(use.names = F) %>% paste(.,collapse=", ")
record <- "select * from edvald_research.umd.corporationApps
where corporationID in (@{corps})" %>% QueryDB(sql.params = list(corps=draw) )

template = seq(as.Date('2015-01-01'),as.Date('2017-04-01'),by='day') %>% data.frame(d=.)  %>%
  mutate(m=month(d),y=year(d)) %>% select(-d)

record %>% mutate(applied = as.numeric(status==0),
                         invited = as.numeric(status==8)) %>% 
  arrange(corporationID,eventDate) %>% select(-status) %>% 
  mutate(m=month(eventDate),y=year(eventDate)) %>% 
  group_by(corporationID,y,m) %>% 
  summarize(applied=sum(applied),invited=sum(invited),total=n()) %>%
  mutate(date = paste(y,m,sep="-")) %>%
  ggplot(.,aes(date,total)) + geom_line(aes(color=as.factor(corporationID))) +
  facet_grid(facets = ~corporationID)



head(record)
