# Generating Coordination Networks Via the Warp To Logs.

require(tidyverse)
require(igraph)

# 'Warp To' Sample...
wsamp = read.csv("~/ETD/selection/data/samp_warpto_logs.csv",header=F,stringsAsFactors = F)
wsamp = wsamp[,-4] # Drop other corp ID
colnames(wsamp) = c("eventDate","corpID","char1","char2","dist")
head(wsamp)
wsamp = wsamp[-1,] # issues with the first row


# sample only contains information for relevant corps for Apr. 1. 2017

wsamp %>% distinct %>% group_by(corpID) %>% tally() %>% arrange(desc(n)) %>% as.data.frame




mapnet = function(cID,title="",simplified=F,commDetect= F,directed=F){
  # Quick function to visualize networks
  em = wsamp %>% distinct %>% filter(corpID==cID) %>% 
    select(char1,char2) %>% as.matrix();colnames(em) = NULL
    actors = unique(c(em[,1],em[,2]))
    net <- graph_from_data_frame(em,actors,directed=directed)
    if(simplified){
      net <- simplify(net)
    }
    if(commDetect){
      comm = cluster_walktrap(net) # using a random walk algorithm to detect communities
      V(net)$color = comm$membership
      plot.igraph(net,vertex.color=V(net)$color,vertex.frame.color="white",
                  edge.color="grey",edge.width=2,vertex.size=5,
                  vertex.label="",main=title,edge.arrow.size=.1)
    } else{
      plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                  edge.color="grey",edge.width=2,vertex.size=5,
                  vertex.label="",main=title,edge.arrow.size=.1)
    }
}


# Let's try pandemic horde for starters 98388312
mapnet(98388312,"Pandemic Horde",simplified=T,
       commDetect = T,directed=F)


# other corporations...
mapnet(98370861,simplified = F,commDetect = T,directed=T) 
mapnet(98431483,simplified = F,commDetect = T) 
mapnet(98479879,simplified = F,commDetect = F,directed=T) 



