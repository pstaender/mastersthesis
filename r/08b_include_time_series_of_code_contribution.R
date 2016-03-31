source('r/include.R')
source('r/include_filtered_repositories.R')   # repositories will be available as global `repositories`
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_firm_employed_developers_on_github.R')
writeOutputAsPDF = T
# cut off below year …
minimumYear = 2000
lineWidth = 3
# int, ext
# customColors = c('#63c000', '#f7c3c3')
customColors = c('#222222', '#FFC748')
# customColors = c('#111111', '#888888')
customLines = c(1, 1)
applyFrequence = 'weekly'
isTopProject <- T
reposTMP <- c(22620547)

Sys.setlocale("LC_TIME", "C")

repositories <- allFirmsRepos

ids <- repositories[repositories$is_top_project == isTopProject, ]$id

section = 'residual'

if (isTRUE(isTopProject)) {
  section = 'top'
}

if (isTRUE(writeOutputAsPDF)) {
  outputAsPDF = paste0("graphics/plots/timeseries/timeseries_code_contribution_", section, ".pdf")
} else {
  outputAsPDF = NULL
}

if (is.character(outputAsPDF)) {
  pdf(outputAsPDF)
  # print("-> OUTPUT AS PDF")
  # par(mfrow=c(2,2))
  lineWidth = lineWidth - 1
}

# only repos from relevant firms
reposTMP <- repositories[repositories$owner.login %in% organizations$login, ]$id

for (repoID in reposTMP) {

  repo <- repositories[repositories$id == repoID, ]
  # section <- repo$name
  csvLogFile <- paste0("data/csv/repositories/logs/logs_", repo$owner.login, "_", repo$name, ".csv")
  
  print(paste0(csvLogFile, ' (', repoID, ')'))
  commitsOverTime <- read.csv(csvLogFile,  header=TRUE, stringsAsFactors = F)
  
  organization <- organizations[organizations$login == repo$owner.login,]
  organizationsEmailPattern <- toString(organization$email_domain)
  
  # hotfix: error in logs_google_ktsan.csv (22620547)
  #   Fehler in strptime(xx, f <- "%Y-%m-%d %H:%M:%OS", tz = tz) : 
  #     Eingabe-Zeichenkette ist zu lang
  
  commitsOverTime = subset(commitsOverTime, nchar(commitsOverTime$date) < 60)
  # convert date format
  commitsOverTime$date = as.Date(as.character(commitsOverTime$date), format ='%a %b %d %Y %H:%M:%S GMT%z')
  # remove N/A
  commitsOverTime <- na.omit(commitsOverTime)
  
  
  commits <- commitsOverTime
  commits$valid_email <- as.logical(regexpr(regexValidEmail, commits$author.email, ignore.case = T) == 1)
  # remove all commits with invalid email addresses from observation
  for (excludePattern in excludeEmailPatterns) {
    commits <- subset(commits, commits$valid_email == T)
    commits$valid_email <- as.logical(regexpr(excludePattern, commits$author.email, ignore.case = T) == -1)
  }
  commits <- subset(commits, commits$valid_email == T)
  # mark all firm employed developers defined by regex pattern in `commercial_classification_of_organizations.csv` for each organization
  commits$is_firm_employed <- as.logical(regexpr(organizationsEmailPattern, commits$author.email, ignore.case = T) >= 0)
  commits <- cbind(commits, is_firm_employed_manually = mapply(isUserFromFirm, commits$author.email, repo$owner.login, T))
  commits[commits$is_firm_employed_manually == T, ]$is_firm_employed <- commits[commits$is_firm_employed_manually == T, ]$is_firm_employed_manually
  
  commitsOverTime <- commits

  diffInDays = max(commitsOverTime$date) - min(commitsOverTime$date)
  if (diffInDays < 365) {
    next
  }
  
  if (diffInDays < 100) {
    applyFrequence = 'daily'
  }
  
  if (diffInDays > 1000) {
    applyFrequence = 'weekly'
  }
  
  applyFrequenceFunction = paste0("apply.", applyFrequence)
  
  commitsOverTime = subset(commitsOverTime, format.Date(commitsOverTime$date, "%Y") > minimumYear )
  commitsOverTime$is_from_firm <- FALSE
  if (nrow(commitsOverTime[commitsOverTime$is_firm_employed == T | commitsOverTime$is_firm_employed_manually == T, ])>0) {
    commitsOverTime[commitsOverTime$is_firm_employed == T | commitsOverTime$is_firm_employed_manually == T, ]$is_from_firm <- TRUE
  }
  
  
  timeFrequency = 12
  
  commitsOverTime$int <- xts(commitsOverTime$is_from_firm == TRUE, commitsOverTime$date, frequency=timeFrequency)
  commitsOverTime$ext <- xts(commitsOverTime$is_from_firm == FALSE, commitsOverTime$date, frequency=timeFrequency)
  monthly <- data.frame(int = do.call(applyFrequenceFunction, list(commitsOverTime$int, sum)))
  monthly$ext <- do.call(applyFrequenceFunction, list(commitsOverTime$ext, sum)) #apply.daily(commitsOverTime$ext, sum)
  monthly$int <- do.call(applyFrequenceFunction, list(commitsOverTime$int, sum)) #apply.daily(commitsOverTime$int, sum)
  # http://blog.revolutionanalytics.com/2014/01/quantitative-finance-applications-in-r-plotting-xts-time-series.html
  basket <- cbind(monthly$int, monthly$ext)
  zoo.basket <- as.zoo(basket)
  tsRainbow <- customColors #topo.colors(ncol(zoo.basket)) # gray.colors
  # basic options -> plot(x = zoo.basket, ylab = "code contributions", main = repo, col = tsRainbow)
  plot(x = zoo.basket, ylab = "code contributions", main = section, col = tsRainbow, screens = 1, lwd=lineWidth, lty=customLines) #lty = "dotted", 
  grid(nx = 4, ny = 4, col = "lightgray", lty = "dotted")
  # Set a legend in the upper left hand corner to match color to return series
  legend(x = "topright", bg = rgb(1,1,1,0.7), bty = "n", legend = c("int","ext"), lty=customLines, lwd=lineWidth, col = tsRainbow)
  
  

  
}

if (outputAsPDF != F) {
  dev.off()
}