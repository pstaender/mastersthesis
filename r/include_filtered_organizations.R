commercialOrganizationsAttributes = c('yes')
organizations <- read.csv(paste0("data/csv/organizations.csv"),  header=T, stringsAsFactors=FALSE)

commercialOrganizations <- read.csv(paste0("data/csv/commercial_classification/commercial_classification_of_organizations.csv"),  header=T, stringsAsFactors=FALSE)

# merge
organizations <- merge(organizations, commercialOrganizations, by = c("login"))
# select specific organizations
organizations <- subset(organizations, organizations$is_commercial %in% commercialOrganizationsAttributes)
# having an email domain
organizations <- organizations[!(organizations$email_domain==""), ]
# for testing: just select one organization to speed up process
# organizations <- subset(organizations, organizations$login %in% c('airbnb'))

print("Info: (Filtered) Organizations are available as gobal `organizations`")