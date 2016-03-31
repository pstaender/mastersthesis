contribs <- subset(contribs, contribs$internal_commits_count < 300)
contribs <- subset(contribs, contribs$external_commits_count < 300)
contribs <- subset(contribs, contribs$internal_commits_count > 20)
contribs <- subset(contribs, contribs$external_commits_count > 20)
