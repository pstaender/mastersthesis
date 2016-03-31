# ls()
# rm(list=ls(all=TRUE))
# getwd()
# setwd("/Users/philipp/masterthesis/")
#
# source('./r/include_filtered_organizations.R')

firmEmployedDevelopersOnGitHub <- read.csv(paste0("data/csv/firm_employed_developers_on_github.csv"), header = T, stringsAsFactors = FALSE)

print("Info: Firm developers are available as gobal `firmEmployedDevelopersOnGitHub`")


manualClassification <- read.csv('data/csv/classification/int_ext_developer_classification.csv', header = T, stringsAsFactors = F)
# assign values to wildcard '*'
manualClassification$done[manualClassification$done == '*'] <- manualClassification$potential_firms[manualClassification$done == '*']
# remove all unclassified / negative classified contributors
manualClassification <- subset(manualClassification, nchar(manualClassification$done) > 1)
# easier to find a match if evryth. is lowercase
manualClassification$done <- tolower(manualClassification$done)
manualClassification$email <- tolower(manualClassification$email)

userFromFirm <- function(userIDOrEmail, firm = NULL) {
  foundUser <- NULL
  email <- NULL
  userID <- NULL
  if (is.numeric(userIDOrEmail)) {
    userID <- userIDOrEmail
    foundUser <- firmEmployedDevelopersOnGitHub[firmEmployedDevelopersOnGitHub$id == userID, ]
  }
  else if (is.character(userIDOrEmail)) {
    email <- tolower(userIDOrEmail)
  }
  if (is.null(foundUser)) {
    # try to find by email
    foundUser <- firmEmployedDevelopersOnGitHub[tolower(firmEmployedDevelopersOnGitHub$email) == email, ]
  }
  if (!is.null(foundUser)) {
    email <- foundUser$email
    for (emailPattern in organizations$email_domain) {
      if (length(grep(emailPattern, email)) > 0) {
        foundUser <- cbind(foundUser, organizations[organizations$email_domain == emailPattern,])
      }
    }
  }
  return(foundUser)
}

isUserFromFirm <- function(userIDOrEmail, firm = NULL) {
  user <- userFromFirm(userIDOrEmail, firm)

  email <- user$email

  if (is.character(userIDOrEmail)) {
    email <- tolower(userIDOrEmail)
  }


  emailInManualClassification <- function(email, organizationLogin) {
    employedInFirms <- manualClassification[manualClassification$email == tolower(email), 1]
    return(tolower(toString(organizationLogin)) %in% tolower(strsplit(toString(employedInFirms), "\\|")[[1]]))
  }

  isFromFirm <- NULL

  if (!is.null(user)) {
    if (!is.null(firm)) {
      isFromFirm <- as.logical(user$login == firm)
    } else {
      isFromFirm <- as.logical(nrow(user)>0)
    }
  } else {
    if (!is.null(email)) {
      # TODO: check csv
    }
  }
  # print(isFromFirm)
  # View(email)
  if (identical(as.logical(length(isFromFirm) > 0), F)) {
    # check manual classification
    isFromFirm <- F
    if (is.character(email)) {
      email <- tolower(userIDOrEmail)
      # print(email)
      # print(firm)
      if (is.character(firm)) {
        return(first(emailInManualClassification(email, firm)))
      }
    }
  }
  return(first(isFromFirm))
}
# so called "test-suite" ;)
isUserFromFirm(817186)                                    # T
isUserFromFirm(817186, 'yahoo')                           # T
isUserFromFirm(817186, 'yelp')                            # F
isUserFromFirm(1)                                         # F
isUserFromFirm('poletti.marco@gmail.com', 'google')       # T
isUserFromFirm('poletti.marco@gmail.com', '')             # F
isUserFromFirm('poletti.marco@gmail.com', 'yelp')         # F
isUserFromFirm('dcramer@gmail.com', 'google')             # F
isUserFromFirm('dcramer@gmail.com', 'dropbox')            # T
isUserFromFirm('dcramer@gmail.com', 'getsentry')          # T
isUserFromFirm('philipp.staender@gmail.com', 'microsoft') # F

# this function should be used for mapply

checkUserIsFirmEmployed <- function(userID, organizationLogin = NULL) {
  #as.logical(
  # employedInFirms <- manualClassification[manualClassification$email == tolower(email), 1]
  if (is.character(organizationLogin)) {
    return(isUserFromFirm(as.numeric(userID), organizationLogin))
  } else {
    return(isUserFromFirm(as.numeric(userID)))
  }
}
