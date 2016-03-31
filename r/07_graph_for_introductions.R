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

# respoitories by (commercial) firms
firmsRepos <- repositories[repositories$is_by_commercial_organization == 'true',]

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

#plotCircleGraph(languages, languages$Stars, languages$Forks, circles = languages$Projects, languages$Language, 'Most popular languages on GitHub 2014', '', 'Stars', 'Forks', NULL, scale = 2)
plotCircleGGraph(languages, aes(x = Stars, y = Forks, group = Language, fill = Language, color = Language, size = Projects), 'Most popular languages on GitHub 2014', '', 'Stars', 'Forks') + 
  scale_size(range = c(0, 60), guide = F) +
  #scale_colour_brewer(palette="Spectral") +
  geom_text(aes(label=Language,fontface="bold"),hjust=2.5, vjust=0.5, size = 5, alpha = 0.2, color = "black", show.legend = F) +
  geom_text(aes(label=Language,fontface="bold"),hjust=2.5, vjust=0.5, size = 5, alpha = 0.4, show.legend = F)

# diverge_hcl diverge_hsl terrain_hcl sequential_hcl rainbow_hcl



#
# # Displaying Organizationdetails
#

#
# ## Licenses
#




allContributions <- read.csv(paste0("data/csv/calculated/contributions_ratio.csv"), header = T, stringsAsFactors=FALSE)
allContributions$all_issues_count <- allContributions$closed_issues_count + allContributions$open_issues_count

allContributions$license_renamed <- gsub("(-| clause)"," ",allContributions$license)
allContributions[allContributions$license_renamed == '',]$license_renamed <- "properietary firm license"

licenses <- data.frame(table(allContributions$license_renamed))
licenses <- subset(licenses, licenses$Freq > 30)
# licenses <- licenses[order(-licenses$Freq),]

myColors <- setColorSchema(licenses, heat.colors)
colorPalette <- rev(palette(myColors))
colorPaletteOpacity <- add.alpha(colorPalette, alpha = 0.3)

relevantContributions <- subset(allContributions, allContributions$license_renamed %in% licenses$Var1)
relevantContributions <- relevantContributions[order(relevantContributions$license_renamed),]

# licenses <- licenses[2:nrow(licenses), ]
# licenses$Var1 <- gsub("(-| clause)"," ",licenses$Var1)
#licenses <- licenses[order(licenses$Freq),]









# ggplot(data=relevantContributions, aes(reorder_size(license_renamed), fill = license_renamed)) +
ggplot(data=relevantContributions, aes(license_renamed, fill = license_renamed)) +
  geom_bar(stat = "count") +
  coord_flip() +
  ylab("Numbers of Repositories") +
  xlab("") +
  ggtitle("Licenses on observed firms projects") +
  # scale_colour_brewer(palette="Paired") # Spectral, Dark2
  scale_fill_brewer(palette=colorPalette)

#
# Group infos about firms repos and calculate a mean/median (contributors, age, ratio ...)
#

library(plyr)

# merge firmsRepos with allOrganizationsRepos --> all details
allContributionsDetails <- allContributions
allContributionsDetails$id <- allContributionsDetails$github_id
firmsRepos <- merge(firmsRepos, allOrganizationsRepos, by = c("id"))
firmsRepos <- merge(firmsRepos, allContributionsDetails, by = c("id"))


groupFirms <- function(calculateGroupValue) {
  ddply(firmsRepos, c("organization_name.x"), summarize,
    issues_count =  calculateGroupValue(issues_count),
    stargazers_count.y = calculateGroupValue(stargazers_count.y),
    size.x = calculateGroupValue(size.x),
    forks_count.x = calculateGroupValue(forks_count.x),
    commits_count = calculateGroupValue(commits_count),
    top_projects_count = sum(is_top_repository == T),
    contributors_count.x = calculateGroupValue(contributors_count.x),
    closed_issues_count.x = calculateGroupValue(closed_issues_count.x),
    open_issues_count.x = calculateGroupValue(open_issues_count.x),
    age.x = calculateGroupValue(age.x),
    subscribers_count = calculateGroupValue(subscribers_count),
    ratio = calculateGroupValue(ratio),
    top_projects_share = calculateGroupValue( sum(top_projects_count) / nrow(firmsRepos)),
    projects_count = sum(id > 0)
  )
}
calculateGroupValue <- function(v) { mean(v) }
groupedFirms <- groupedByFirmMean <- groupFirms(calculateGroupValue)

calculateGroupValue <- function(v) { median(v) }
groupedByFirmMedian <- groupFirms(median)

# display graph

xAxis <- groupedFirms$age
yAxis <- groupedFirms$ratio
circleSize <- groupedFirms$top_projects_share

symbols(xAxis, yAxis, circles=circleSize, inches=1, ann=F, bg=colorPaletteOpacity, fg=NULL)#steelblue2
title(main="Firm's Open Source Projects (Top Projects Share)", xlab="Age", ylab="Ratio")
shadowtext(
  x=xAxis,
  y=yAxis,
  labels = groupedFirms$organization_name.x,
  cex = 0.8,
  col = add.colorBrightness(colorPalette, 0.5),
  bg = "white",
  r = 0.05
)
simpleGridOverlay(0.05)



xAxis <- groupedFirms$projects_count
yAxis <- groupedFirms$ratio
circleSize <- groupedFirms$top_projects_count

symbols(xAxis, yAxis, circles=circleSize, inches=1, ann=F, bg=colorPaletteOpacity, fg=NULL)#steelblue2
title(main="Firm's Open Source Projects", sub="Size: Numbers of top projects", xlab="Number of Firm's OS Projects", ylab="Ratio")
shadowtext(
  x=xAxis,
  y=yAxis,
  labels = groupedFirms$organization_name.x,
  cex = 0.8,
  col = add.colorBrightness(colorPalette, 0.5),
  bg = "white",
  r = 0.05
)
simpleGridOverlay(0.05)










if (outputAsPDF != F) {
  dev.off()
}


# Experimenting with ggplot




# theme(axis.text = element_text(family="Times"))
# a <- ggplot(data = languages, aes(x = Stars, y = Forks, group = Language, color = Language, size = Projects))
# a <- a + geom_point(alpha = 0.8) + geom_line()
# a <- a + scale_size(range = c(0, 120), guide = F)
# a <- a + scale_y_continuous(labels = comma)
# #a <- a + scale_colour_gradient(low = "blue")
# a <- a + xlab("stars count") + ylab("forks count") + ggtitle("Popular programming languages on GitHub")
# a
