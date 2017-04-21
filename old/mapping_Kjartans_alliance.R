# Mapping the network of Kjartan's alliance 
library(tidyverse)
library(revemetrics)

# This referencing a temporary table I made of the alliances in Kjartan's corp. 
kall = "select * from edvald_research.umd.kartanAlliance" %>% QueryDB()

em = kall %>% distinct %>% 
  select(characterID,toCharID) %>% as.matrix();colnames(em) = NULL
actors = unique(c(em[,1],em[,2]))
net <- graph_from_data_frame(em,actors,directed=F)
# net <- simplify(net)
plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
            edge.color="grey",edge.width=2,vertex.size=5,
            vertex.label="",main="Kjartan's Alliance")


# ID corps by color
chCp = rbind(kall %>% select(characterID,corporationID,name=cpname) %>% 
  distinct() %>% as.data.frame(.), 
kall %>% select(characterID=toCharID,corporationID=toCorpID,name=tocpname) %>% 
  distinct() %>% as.data.frame(.)) %>% distinct

cols = c(RColorBrewer::brewer.pal(9,"Set1"),RColorBrewer::brewer.pal(8,"Set2"))
cmap = data.frame(corporationID=unique(chCp$corporationID),color=cols,stringsAsFactors = F) %>% 
merge(chCp,.,by="corporationID")

V(net)$color = cmap$color[match(actors,cmap$characterID)]
V(net)$cpname = cmap$name[match(actors,cmap$characterID)]

# Export Graph
pdf("~/ETD/selection/figures/kjartans_alliance.pdf",height=10,width=10)
plot.igraph(net,vertex.color=V(net)$color,vertex.frame.color="white",
            edge.color="grey",edge.width=2,vertex.size=5,
            vertex.label="",main="Kjartan's Alliance\nApril 1, 2017")
legend('topright',legend=unique(V(net)$cpname),col=unique(V(net)$color),pch=15,cex=.7,box.col="white",title="Corp. Names")
dev.off()