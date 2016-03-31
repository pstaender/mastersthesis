#------------------------------------------------------------------#
#
# Draw graphs for introduction
#
#------------------------------------------------------------------#
# Author: Philipp Staender (philipp.staender@rwth-aachen.de)       #
#------------------------------------------------------------------#

## 1. Loading and preparing R
## 1.1 Reset environment
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("/Users/philipp/masterthesis/")

outputAsPDF = F#paste0("graphics/introduction.pdf")
lineWidth = 3

if (outputAsPDF != F) {
  pdf(outputAsPDF, width=10, height=10)
  lineWidth = lineWidth - 1
}

commercialOrganizationsAttributes = c('yes')

# This includes some helper methods (e.g. latex export, pdf export …)
source('r/include.R')
source('r/include_filtered_repositories.R')   # repositories will be available as global `repositories`
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
require('TeachingDemos') # require('colorspace')
require('plyr')

# respoitories by (commercial) firms
firmsRepos <- repositories[repositories$is_by_commercial_organization == 'true',]
firmsRepos <- subset(firmsRepos, firmsRepos$language %in% OBSERVED_LANGUAGES)

# 1.setup gplot
library(ggplot2)
require(scales)
theme_set(theme_gray(base_size = 18))


# load the generated CSV file with all popular repositories for all 10 programming languges:

setColorSchema <- function(data, myPalette) { rainbow(nrow(data)) }
reorder_size <- function(x) { factor(x, levels = names(sort(table(x)))) }
rev_reorder_size <- function(x) { factor(x, levels = names(rev(sort(table(x))))) }

plotCircleGraph <- function(data, x, y, circles, labels = NULL, title = '', subtitle = '', xAxisText = 'x', yAxisText = 'y', colorScheme = NULL, scale = 2) {
  # Use built in R plot
  if (is.null(colorScheme)) {
    colorScheme <- colorPaletteOpacity
  }
  symbols(x=x, y=y, circles, ann=F, bg=colorScheme, fg=NULL, inches = scale)
  title(main=title, xlab=xAxisText, ylab=yAxisText)
  if (!is.null(labels)) {
    shadowtext(
      x=x,
      y=y,
      labels = labels,
      cex = 0.8,
      col = add.colorBrightness(colorPalette, 0.5),
      bg = "white",
      r = 0.05
    )
    simpleGridOverlay(0.05)
  }
}

plotCircleGGraph <- function(data, aesFunc, title = '', subtitle = '', xAxisText = 'x', yAxisText = 'y', colorScheme = NULL) {
  # scale_size(range = c(0, 120), guide = F) +
  # scale_colour_brewer(palette="Paired") # Spectral, Dark2
  a <- ggplot(data = data, aesFunc)
  a <- a + geom_point(alpha = 0.8) + geom_line()
  a <- a + scale_y_continuous(labels = comma)
  a <- a + xlab(xAxisText) + ylab(yAxisText) + ggtitle(title)
  a
}


## 2. Plotting data



languages <- read.csv(paste0("data/csv/popular_programming_languages_on_github.csv"), header = T, stringsAsFactors=FALSE, comment.char = "#")
languages <- subset(languages, languages$Stars > 0 & languages$Forks > 0)

myColors <- setColorSchema(languages, heat.colors)
colorPalette <- rev(palette(myColors))
colorPaletteOpacity <- add.alpha(colorPalette, alpha = 0.3)

# --> graphics/intro/popular_programming_languages

plotCircleGGraph(languages, aes(x = Stars, y = Forks, group = Language, fill = Language, color = Language, size = Projects), '', '', 'Stars', 'Forks') + 
  scale_size(range = c(0, 60), guide = F) +
  #scale_colour_brewer(palette="Spectral") +
  geom_text(aes(label=Language,fontface="bold"),hjust=2.5, vjust=0.5, size = 5, alpha = 0.2, color = "black", show.legend = F) +
  geom_text(aes(label=Language,fontface="bold"),hjust=2.5, vjust=0.5, size = 5, alpha = 0.4, show.legend = F)


#
# # Displaying Organizationdetails
#

#
# ## Languages use for every firm
#


relevantOrgs <- subset(organizations, organizations$number_of_distinct_repos > 4)


allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T, stringsAsFactors=FALSE)
allContributions <- subset(allContributions, allContributions$language %in% OBSERVED_LANGUAGES)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count
allContributions$license_renamed <- gsub("(-| clause)"," ",allContributions$license)
allContributions[allContributions$license_renamed == '',]$license_renamed <- "other license"
allContributions <- subset(allContributions, allContributions$language %in% OBSERVED_LANGUAGES)
allContributions <- subset(allContributions, allContributions$organization_name %in% relevantOrgs$login)

ag.languages <- aggregate(allContributions$language, by=list(allContributions$organization_name, allContributions$language), FUN=length)
ag.languages <- rename(ag.languages, c("Group.1" = "Firm", "Group.2" = "Language"))

# for sorted bars
orgList <- aggregate(allContributions$organization_name, by=list(allContributions$organization_name), FUN=length)
orgList <- orgList[order(- orgList$x),]

# --> graphics/intro/programming_language_use_by_firms

ggplot(ag.languages,aes(x=factor(ag.languages$Firm),y=ag.languages$x,fill=factor(ag.languages$Language)), color=factor(ag.languages$Firm)) +  
  stat_summary(fun.y=mean,position="stack",geom="bar") +
  coord_flip() +
  scale_x_discrete(limits=rev(orgList$Group.1)) +
  scale_fill_discrete(name="Programming\nLanguage") +
  # geom_bar(stat = "count") +
  xlab("") +
  ylab("Number of Repositories")
  # ggtitle("Programming Language usage by Firms")




allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T, stringsAsFactors=FALSE)
allContributions <- subset(allContributions, allContributions$language %in% OBSERVED_LANGUAGES)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count
allContributions$license_renamed <- gsub("(-| clause)"," ",allContributions$license)
allContributions[allContributions$license_renamed == '',]$license_renamed <- "unspecified"
# allContributions <- subset(allContributions, allContributions$language %in% OBSERVED_LANGUAGES)


ag.licenses <- aggregate(allContributions$license_renamed, by=list(allContributions$organization_name, allContributions$license_renamed), FUN=length)
ag.licenses <- rename(ag.licenses, c("Group.1" = "Firm", "Group.2" = "License"))

# for sorted bars
myList <- aggregate(allContributions$license_renamed, by=list(allContributions$license_renamed), FUN=length)
myList <- myList[order(- myList$x),]

# license usage

ggplot(ag.licenses,aes(x=factor(ag.licenses$License),y=ag.licenses$x,fill=factor(ag.licenses$Firm)), color=factor(ag.licenses$License)) +  
  stat_summary(fun.y=mean,position="stack",geom="bar") +
  coord_flip() + 
  scale_x_discrete(limits=rev(myList$Group.1)) +
  scale_fill_discrete(name="Firm") +
  xlab("") +
  ylab("Number of Repositories") +
  ggtitle("")

sortedLicenses <- c("agpl 3.0","gpl 2.0","gpl 3.0","cc0 1.0","ofl 1.1","lgpl 2.1","lgpl 3.0","apache 2.0","epl 1.0","isc","mpl 2.0","ms pl","wtfpl","bsd 2 clause","bsd 3 clause","mit","unlicense","other","unspecified")


# what firm is using which license?
# sort by "sortedLicenses" order
ag.licenses <- ag.licenses[order(match(ag.licenses$License, sortedLicenses)),]

# myList <- aggregate(allContributions$organization_name, by=list(allContributions$license_renamed), FUN=length)
# myList <- orgList[order(- orgList$x),]

# ag.licenses2 <- ag.licenses[order(match(ag.licenses$Firm, orgList$Group.1)),]

# --> graphics/intro/which_firm_is_using_which_license

ggplot(ag.licenses,aes(x=factor(ag.licenses$Firm),y=ag.licenses$x,fill=factor(ag.licenses$License, as.character(ag.licenses$License))), color=factor(ag.licenses$Firm)) +  
  stat_summary(fun.y=mean,position="stack",geom="bar") +
  coord_flip() + 
  #scale_fill_manual(values = ag.licenses$License) + 
  scale_x_discrete(limits=organizations[order(organizations$public_repos),]$login) +
  scale_y_discrete(breaks = NULL) +
  scale_fill_discrete(name="License\nType") +
  # geom_bar(stat = "count") +
  xlab("") +
  ylab("")





## Firm repositories
## TODO: weitermachen

allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T, stringsAsFactors=FALSE)
allContributions <- subset(allContributions, allContributions$language %in% OBSERVED_LANGUAGES)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count
allContributions$license_renamed <- gsub("(-| clause)"," ",allContributions$license)
allContributions[allContributions$license_renamed == '',]$license_renamed <- "unspecified"
allContributions$project_type <- 'Residual Projects'
allContributions[allContributions$is_top_project == T, ]$project_type <- 'Top Projects'
allContributions <- subset(allContributions, allContributions$is_top_project == F)

ag.licenses <- aggregate(allContributions$license_renamed, by=list(allContributions$organization_name, allContributions$license_renamed), FUN=length)
ag.licenses <- rename(ag.licenses, c("Group.1" = "Firm", "Group.2" = "License"))

# for sorted bars

myList <- aggregate(allContributions$license_renamed, by=list(allContributions$license_renamed), FUN=length)
myList <- myList[order(- myList$x),]

# license usage

# manual sorting
sortedLicenses <- c("epl 1.0","lgpl 3.0","cc0 1.0","agpl 3.0","bsd 2 clause","gpl 2.0","other","unspecified","apache 2.0", "mit","bsd 3 clause","isc","mpl 2.0","gpl 3.0","unlicense","lgpl 2.1","wtfpl","mspl")
classifiedLicenses <- c("agpl 3.0","gpl 2.0","gpl 3.0","cc0 1.0","ofl 1.1","lgpl 2.1","lgpl 3.0","apache 2.0","epl 1.0","isc","mpl 2.0","ms pl","wtfpl","bsd 2 clause","bsd 3 clause","mit","unlicense","other","unspecified")

classifiedOrder <- myList[order(match(myList$Group.1, classifiedLicenses)),]
myList <- myList[order(match(myList$Group.1, sortedLicenses)),]

# --> graphics/intro/popular_license_classes_for_firms
# falsch!
ggplot(myList,aes(x=factor(myList$Group.1),y=myList$x, fill = factor(classifiedOrder$Group.1, as.character(classifiedOrder$Group.1))), color=factor(classifiedOrder$Group.1)) +  
  stat_summary(fun.y=mean,position="stack",geom="bar") +
  scale_x_discrete(limits=rev(myList$Group.1), breaks = NULL) +
  scale_fill_discrete(name="License\n") +
  xlab("") +
  ylab("Repositories") +
  ggtitle("")

# richtig
ggplot(myList,aes(x=factor(myList$Group.1),y=myList$x, fill = factor(myList$Group.1, as.character(myList$Group.1))), color=factor(classifiedOrder$Group.1)) +  
  stat_summary(fun.y=mean,position="stack",geom="bar") +
  scale_x_discrete(limits=rev(myList$Group.1), breaks = NULL) +
  scale_fill_discrete(name="License\n") +
  xlab("") +
  ylab("Repositories") +
  ggtitle("")






allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T, stringsAsFactors=FALSE)
allContributions <- subset(allContributions, allContributions$language %in% OBSERVED_LANGUAGES)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count
allContributions$license_renamed <- gsub("(-| clause)"," ",allContributions$license)
allContributions[allContributions$license_renamed == '',]$license_renamed <- "unspecified"
allContributions$project_type <- 'Residual Projects'
allContributions[allContributions$is_top_project == T, ]$project_type <- 'Top Projects'

sortedLicenses <- c("epl 1.0","lgpl 3.0","cc0 1.0","agpl 3.0","bsd 2 clause","gpl 2.0","other","unspecified","apache 2.0", "mit","bsd 3 clause","isc","mpl 2.0","gpl 3.0","unlicense","lgpl 2.1","wtfpl","mspl")
classifiedLicenses <- c("agpl 3.0","gpl 2.0","gpl 3.0","cc0 1.0","ofl 1.1","lgpl 2.1","lgpl 3.0","apache 2.0","epl 1.0","isc","mpl 2.0","ms pl","wtfpl","bsd 2 clause","bsd 3 clause","mit","unlicense","other","unspecified")

# --> graphics/intro/popular_license_classes_for_firms

ggplot(allContributions,aes(factor(allContributions$license_renamed), fill = allContributions$license_renamed, order = -as.numeric(cut))) +
  geom_bar() +
  scale_x_discrete(breaks = NULL, limits=(sortedLicenses)) +
  facet_wrap(~project_type) +
  scale_fill_discrete(name="Licenses\n") +
  xlab("") +
  ylab("Number of Repositories") 







# --> graphics/info/languages_used_in_projects

#ag.languages <- length(allContributions$language)
#fill = unique(allContributions$language)
ggplot(allContributions,aes(factor(allContributions$language), fill = allContributions$language)) +
  geom_bar() + 
  # stat_summary(fun.y=mean,position="stack",geom="bar") +
  scale_x_discrete(breaks = NULL, limits=(c('Objective-C','C','C#','Go','C++','Java','JavaScript','Ruby','Python','PHP'))) +
  facet_wrap(~project_type) +
  scale_fill_discrete(name="Programming\nLanguage\n") +
  xlab("") +
  ylab("Number of Repositories") 
  











## STARS

# plotCircleGGraph(languages, aes(x = Stars, y = Forks, group = Language, fill = Language, color = Language, size = Projects), '', '', 'Stars', 'Forks') + 
#   scale_size(range = c(0, 60), guide = F) +
#   #scale_colour_brewer(palette="Spectral") +
#   geom_text(aes(label=Language,fontface="bold"),hjust=2.5, vjust=0.5, size = 5, alpha = 0.2, color = "black", show.legend = F) +
#   geom_text(aes(label=Language,fontface="bold"),hjust=2.5, vjust=0.5, size = 5, alpha = 0.4, show.legend = F)


allContributions$ratio_size <- exp(allContributions$ratio)*10

observations <- allContributions
observations$Firm <- observations$organization_name
observations$Forks <- observations$forks_count
observations$Subscribers <- observations$subscribers_count
observations$`Code Commits by Firm Developers` <- observations$internal_commits_count
observations$Ratio <- observations$ratio
observations$Contributors <- observations$contributors_count
observations$`Top Project` <- 'no'
observations$Stars <- observations$stargazers_count
observations$Age <- observations$age
observations[observations$is_top_project == T,]$`Top Project` <- 'yes'

# --> graphics/intro/code_contribution_absolute

obs <- observations
obs <- subset(observations, observations$organization_name %in% c('google','Microsoft','heroku','adafruit','Automattic','facebook'))
# PDF 11x15 inch
# SVG 1900x1200 px

# ggplot(data = obs, legend=TRUE, aes(Forks, Subscribers)) +
#   geom_point(data = obs, mapping=aes(size=`Code Commits by Firm Developers`, shape=`Top Project`, color = Firm), alpha = 0.6) +
#   guides(fill=guide_legend(title=NULL)) +
#   scale_x_continuous(limits = c(10, 1000)) + 
#   scale_y_continuous(limits = c(10, 500)) +
#   xlab("Forks") +
#   ylab("Subscribers") 

#log(`Code Commits by Firm Developers`)
ggplot(data = obs, legend=TRUE, aes(Age, Stars)) +
  geom_point(data = obs, mapping=aes(size=log(`Code Commits by Firm Developers`), shape=`Top Project`, color = Firm), alpha = 0.6) +
  guides(fill=guide_legend(title=NULL)) +
  scale_x_continuous(limits = c(350, 1500)) + 
  scale_y_continuous(limits = c(0, 3000)) +
  xlab("Age") +
  ylab("Stargazers")


ggplot(data = obs, legend=TRUE, aes(Age, Stars)) +
  geom_point(data = obs, mapping=aes(size=Ratio, shape=`Top Project`, color = Firm), alpha = 0.6) +
  guides(fill=guide_legend(title=NULL)) +
  scale_x_continuous(limits = c(350, 1500)) + 
  scale_y_continuous(limits = c(0, 3000)) +
  xlab("Age") +
  ylab("Stargazers")





obs <- subset(obs, obs$ratio <= 0.25) # obs <- subset(obs, obs$ratio >= 0.75)

ggplot(data = obs, legend=TRUE, aes(Stars, Contributors)) +
  geom_point(data = obs, mapping=aes(size=Ratio, color = `Top Project`), alpha = 0.6) +
  guides(fill=guide_legend(title=NULL)) +
  scale_x_continuous(limits = c(0, 5000)) +
  scale_y_continuous(limits = c(0, 400))
  # xlab("") +
  # ylab("Stargazers")

obs <- observations
obs$`firm's code commit share` <- 'less than 50%'
obs[obs$ratio >= 0.5,]$`firm's code commit share` <- 'more/equal than 50%'
#obs <- obs[order(-obs$ratio),]

ggplot(data = obs, legend=TRUE, aes(Stars, Subscribers)) +
  geom_point(data = obs, mapping=aes(size=`firm's code commit share`, color = `Top Project`), alpha = 0.6) +
  guides(fill=guide_legend(title=NULL)) +
  scale_x_continuous(limits = c(100, 15000)) +
  scale_y_continuous(limits = c(100, 1500))

ggplot(data = obs, legend=TRUE, aes(Stars, Subscribers)) +
  geom_point(data = obs, mapping=aes(color=`firm's code commit share`, size = `Top Project`), alpha = 0.6) +
  guides(fill=guide_legend(title=NULL)) +
  scale_x_continuous(limits = c(100, 15000)) +
  scale_y_continuous(limits = c(100, 1500))

ggplot(data = obs, legend=TRUE, aes(Stars, Subscribers)) +
  geom_point(data = obs, mapping=aes(size=`firm's code commit share`, color=`Top Project`), alpha = 0.6) +
  guides(fill=guide_legend(title=NULL)) +
  scale_x_continuous(limits = c(50, 1000)) +
  scale_y_continuous(limits = c(50, 400))

  # scale_size_area()
# xlab("") +
# ylab("Stargazers")


