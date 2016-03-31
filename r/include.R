# requirements
require(foreign)
require(MASS)
library(xtable)
library(stargazer)
library(stringr)
library(lme4)

# require x11
# capabilities('X11')

# par(mfrow=c(1,1))

## Convert csv data for latex

# session ID is used to produce time dependent file names
sessionID <- 0

refreshSessionID <- function() {
  sessionID <<- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
}

refreshSessionID()

# csvToLatex <- function(path, prefix = paste0('_', sessionID)) {
#   t <- read.csv(path)
#   t_data <- print(xtable(t),floating=FALSE)
#   fileName = paste0("tables/", gsub("^(.*\\/)(.+?)\\.csv$",'\\2',path), prefix, ".tex")
#   write(t_data, file = fileName)
# }
tableToLatexFile <- function(data, name, prefix = paste0('_', sessionID), extension = '.tex') {
  # reorder row number
  row.names(data) <- 1:nrow(data)
  data <- print(xtable(data), floating = F)
  write(data, file = paste0(name, prefix, extension))
}

# csvToLatexTable <- function(name, data, prefix = paste0('_', format(Sys.time(), "%Y-%m-%d_%H-%m-%S"))) {
#   t_data <- print(xtable(data),floating=FALSE)
#   fileName = paste0("tables/", gsub("^(.*\\/)(.+?)\\.csv$",'\\2', name), prefix, ".tex")
#   write(t_data, file = fileName)
# }

dataToLatex <- function(data, fileName, prefix = paste0(format(Sys.time(), "%Y-%m-%d_%H-%m-%S"))) {
  fileName = paste0(fileName, '_', prefix, ".tex")
  write(data, file = fileName)
}

writeToFile <- function(data, fileName, prefix = paste0('_', format(Sys.time(), "%Y-%m-%d_%H-%m-%S"))) {
  if (any(grep('\\.tex$', fileName, ignore.case = TRUE))) {
    fileName = paste0(gsub("^(.*\\/)(.+?)\\.tex$",'\\1\\2',fileName), prefix, ".tex")
    # fileName = paste0(fileName, prefix, ".tex")
    write(stargazer(data, summary=F), file = fileName)
  }
  else if (any(grep('\\.t(e)*xt$', fileName, ignore.case = TRUE))) {
    fileName = paste0(gsub("^(.*\\/)(.+?)\\.txt$",'\\1\\2',fileName), prefix, ".txt")
    # fileName = paste0(fileName, prefix, ".txt")
    write(data, file = fileName)
  }
  else if (any(grep('\\.csv$', fileName, ignore.case = TRUE))) {
    fileName = paste0(gsub("^(.*\\/)(.+?)\\.csv$",'\\1\\2',fileName), prefix, ".csv")
    # fileName = paste0(fileName, prefix, ".csv")
    write.csv(data, file = fileName, row.names=F)
  }
}

askForDataPrompt <- function(data) {
  prompt <- readline("Display data? (y/N/edit) ")
  if(grepl("^(y|yes)", prompt, ignore.case=TRUE)) {
    View(data)
  }
  if(grepl("edit", prompt, ignore.case=TRUE)) {
    edit(data)
  }
}

writeContentToFile <- function(content, filename, type, additional = F, longtable = F ) {
  if (type == 'text') {
    fileExtension = 'md'
  } else if (type == 'latex') {
    fileExtension = 'tex'
    if (longtable == T) {
      content = gsub("^.{1}begin\\{tabular\\}", "\\\\begin{longtable}", content)
      content = gsub("^.{1}end\\{tabular\\}", "\\\\end{longtable}", content)
    }
  } else {
    fileExtension = type
  }
  filename = paste0(filename, '.', fileExtension)
  write(content, file = filename)
  if ((type == 'text') && (typeof(additional) == 'character')) {
    write(additional, file = filename, append = T)
  }
}

regexValidEmail = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
excludeEmailPatterns = c(
  "\\.local(domain|host)*$",
  "users\\.noreply\\.github\\.com$",
  "@localhost$",
  "@example\\.com$"
)

# Source add.alpha function from Github
# require(RCurl)
# source(textConnection(getURL("https://gist.github.com/mages/5339689/raw/576263b8f0550125b61f4ddba127f5aa00fa2014/add.alpha.R")))

## Add an alpha value to a colour
add.alpha <- function(col=NULL, alpha=1){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2,
        function(x)
          rgb(x[1], x[2], x[3], alpha=alpha))
}

add.colorBrightness <- function(col=NULL, brightness=0.5){
  if(missing(col))
    stop("Please provide a vector of colours.")
  apply(sapply(col, col2rgb)/255, 2,
        function(x)
          rgb(x[1]*brightness, x[2]*brightness, x[3]*brightness))
}

simpleGridOverlay <- function(alpha=0.1) {
  axis(1, tck=1, labels = F, col.ticks=add.alpha(c("#000000"), alpha))
  axis(2, tck=1, labels = F, col.ticks=add.alpha(c("#000000"), alpha))
}

# concats a vector to string
implode <- function(..., sep='|') {
  paste(..., collapse=sep)
}

# Needed to cast dates correctly (i.e. interpret day and month abbrevations correctly / Mon Tue Wed ...)
Sys.setlocale("LC_TIME", "C")

OBSERVED_LANGUAGES <- c('C++','C#','C','Ruby','Java','JavaScript','Go','Objective-C','PHP','Python')

# Note: file.choose()
