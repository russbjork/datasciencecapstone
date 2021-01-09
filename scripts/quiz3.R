## Analyze the Corpus data
################################################################################
## For each of the sentence fragments below use your natural language processing
## algorithm to predict the next word in the sentence.


en_3gramRDS = "data/final/en_US/en_3gramRDS.rds"
df <- readRDS(en_3gramRDS)
## 1. When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd
##    give,eat,die,sleep
rbind(head(df[grep("live and give", df[,1]),],10),
      head(df[grep("live and eat", df[,1]),],10),
      head(df[grep("live and die", df[,1]),],10),  #top and correct
      head(df[grep("live and sleep", df[,1]),]),10)
## 2. Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his
##    financial, horticultural,spiritual,marital
rbind(head(df[grep("about his financial", df[,1]),],10),
      head(df[grep("about his horticultural", df[,1]),],10),
      head(df[grep("about his spiritual", df[,1]),],10),  #top
      head(df[grep("about his marital", df[,1]),]),10)  #correct
## 3. I'd give anything to see arctic monkeys this
##    morning,decade,month,weekend
rbind(head(df[grep(" this morning", df[,1]),],10),  #top
      head(df[grep(" this decade", df[,1]),],10),
      head(df[grep(" this month", df[,1]),],10),
      head(df[grep(" this weekend", df[,1]),]),10)  #correct
## 4. Talking to your mom has the same effect as a hug and helps reduce your
##    happiness,sleepiness,stress,hunger
rbind(head(df[grep("reduce your happiness", df[,1]),],10),
      head(df[grep("reduce your sleepiness", df[,1]),],10),
      head(df[grep("reduce your stress", df[,1]),],10),  #top and correct
      head(df[grep("reduce your hunger", df[,1]),]),10)
## 5. When you were in Holland you were like 1 inch away from me but you hadn't time to take a
##    minute,look,walk,picture
rbind(head(df[grep("reduce your happiness", df[,1]),],10),
      head(df[grep("reduce your sleepiness", df[,1]),],10),
      head(df[grep("reduce your stress", df[,1]),],10),  #top and correct
      head(df[grep("reduce your hunger", df[,1]),]),10)
## 6. I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the
##    matter,incident,case,account
rbind(head(df[grep("reduce your happiness", df[,1]),],10),
      head(df[grep("reduce your sleepiness", df[,1]),],10),
      head(df[grep("reduce your stress", df[,1]),],10),  #top and correct
      head(df[grep("reduce your hunger", df[,1]),]),10)
## 7. I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each
##    finger,toe,hand,arm
rbind(head(df[grep("reduce your happiness", df[,1]),],10),
      head(df[grep("reduce your sleepiness", df[,1]),],10),
      head(df[grep("reduce your stress", df[,1]),],10),  #top and correct
      head(df[grep("reduce your hunger", df[,1]),]),10)
## 8. Every inch of you is perfect from the bottom to the
##    middle,side,center,top
rbind(head(df[grep("reduce your happiness", df[,1]),],10),
      head(df[grep("reduce your sleepiness", df[,1]),],10),
      head(df[grep("reduce your stress", df[,1]),],10),  #top and correct
      head(df[grep("reduce your hunger", df[,1]),]),10)
## 9. I’m thankful my childhood was filled with imagination and bruises from playing
##    weekly,inside,daily,outside
rbind(head(df[grep("reduce your happiness", df[,1]),],10),
      head(df[grep("reduce your sleepiness", df[,1]),],10),
      head(df[grep("reduce your stress", df[,1]),],10),  #top and correct
      head(df[grep("reduce your hunger", df[,1]),]),10)
## 10. I like how the same people are in almost all of Adam Sandler's
##    pictures,movies,novels,stories
rbind(head(df[grep("reduce your happiness", df[,1]),],10),
      head(df[grep("reduce your sleepiness", df[,1]),],10),
      head(df[grep("reduce your stress", df[,1]),],10),  #top and correct
      head(df[grep("reduce your hunger", df[,1]),]),10)