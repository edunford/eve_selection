library(revemetrics)
library(tidyverse)
library(igraph)
library(networkDynamic)
require(ndtv)
require(ggthemes)
require(RColorBrewer)

# Mapping Alliance Cohesion Patterns?
"
select *
from edvald_research.umd.warptologs_meta
where allianceID = toAllID and allianceID = 99006109
" %>% QueryDB() -> A1

#save(A1,file="~/ETD/selection/code/examples/alliance_99006109.Rdata")


head(A1)

A1 %>% group_by(corporationID) %>% tally()

# Interaction Trend
A1 %>% group_by(eventDate) %>% tally() %>% arrange(eventDate) %>% 
  ggplot(data=.,aes(x=as.Date(eventDate),y=n)) + 
  geom_line(lwd=1,color="orange")+ theme_hc()

# Interaction Trend (by corp)
A1 %>% group_by(eventDate,corporationID) %>% tally() %>% arrange(eventDate) %>% 
  ggplot(data=.,aes(x=as.Date(eventDate),y=n)) + 
  geom_line(lwd=1)+ theme_hc() + facet_wrap(facets=~corporationID,ncol=4)


# The STATIC Network ----------------------------------------------

    # Allocating Color Scheme
    qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
    col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
    chCp = rbind(A1 %>% select(characterID,corporationID) %>% 
                   distinct() %>% as.data.frame(.), 
                 A1 %>% select(characterID=toCharID,corporationID=toCorpID) %>% 
                   distinct() %>% as.data.frame(.)) %>% distinct
    cmap = data.frame(corporationID=unique(chCp$corporationID),
                      color=col_vector[1:32],stringsAsFactors = F) %>% 
      merge(chCp,.,by="corporationID")

    
# By individuals clustered within corporations 
  em = A1 %>% #filter(eventDate=='2016-10-04') %>% 
    distinct %>% 
    select(characterID,toCharID) %>% as.matrix();colnames(em) = NULL
  actors = unique(c(em[,1],em[,2]))
  net <- graph_from_data_frame(em,actors,directed=T)
  V(net)$color = cmap$color[match(actors,cmap$characterID)]
  V(net)$corporationID = cmap$corporationID[match(actors,cmap$characterID)]
  plot.igraph(net,vertex.color=V(net)$color,vertex.frame.color="white",
              edge.color="grey",edge.arrow.size=0.3,edge.width=2,vertex.size=5,
              vertex.label="",main="") 
  legend('topright',legend=unique(V(net)$corporationID),col=unique(V(net)$color),pch=15,cex=.7,box.col="white",title="Corp. Names")
  
# By corporation
  em = A1 %>% filter(eventDate=='2016-10-04') %>% 
    select(corporationID,toCorpID) %>% 
    filter(corporationID!=toCorpID) %>% 
    as.matrix();colnames(em) = NULL
  actors = unique(c(em[,1],em[,2]))
  net <- graph_from_data_frame(em,actors,directed=F)
  #net = simplify(net)
  V(net)$color = cmap$color[match(actors,cmap$corporationID)]
  V(net)$corporationID = cmap$corporationID[match(actors,cmap$corporationID)]
  plot.igraph(net,vertex.color=V(net)$color,vertex.frame.color="white",
              edge.color="grey",edge.arrow.size=0.3,edge.width=2,vertex.size=5,
              vertex.label="",main="") 
  legend('topright',legend=unique(V(net)$corporationID),
         col=unique(V(net)$color),pch=15,cex=.7,
         box.col="white",title="Corp. Names")






render.d3movie(network(net),output.mode = 'htmlWidget')
