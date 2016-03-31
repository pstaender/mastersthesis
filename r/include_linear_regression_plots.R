plotLinearRegression <- function(attribs, data) {
  for (attribute in attribs) {
    # par(mfrow=c(2,2))
    # YVAR ~ XVAR
    # YVAR is the dependent, or predicted variable
    # XVAR is the independent, or predictor, variable
    # lm (y ~ x)
    # lm (attribute ~ ratio)
    # x -> y , ratio -> stars, ratio influeces stars, ratio ~ x
    # example:  lm(sales ~ adverts) -> advertising predicts sales
    # From: Field, Andy. „Discovering Statistics Using R.“
    # 2nd example:
    #   * we want to predict sales from the variables adverts, airplay and attract
    #     -> lm(sales ~ adverts + airplay + attract, data = album2)
    
    ratio = contributions$ratio
    x = contributions[[attribute]]
    
    fm <- lm(x ~ ratio)
    outlierTest(fm)
    # leveragePlots(fm)
    fitted.values(fm)
    resid = residuals(fm)
    plot(
      x,
      ratio,
      xlab=attribute,
      ylab="ratio int/ext",
      main = title,
      # sub = 'subtitle',
      type = "p",
      col = "grey",
      pch = 16
    )
    abline(fm, col = "red")
  }
}




# dataToLatex(summary, 'statistics/summary/summary', title)

# subtitleNice = paste0(nrow(contributions), " ", groupBy, " observed, ", gsub("[_]+",' ',section), " selection of  repos.")

# writes summary of csv data (min, max, median …)
# writeOutputFiles = F
# if (writeOutputFiles == T) {
#   
#   # select only relevant columns for summary
#   # summaryData <- cbind(contributions[names(contributions) %in% summaryFields])
#   
#   for (fileFormat in c("text", "latex")) {
#     # summary = stargazer( linear.1, linear.2, linear.3, linear.4, type=fileFormat, title = paste0("Regression Results ", "(",subtitleNice,")"))
#     #     outputFilename = paste0("statistics/summary/tex/result1", ".", fileFormat)
#     #     writeToFile(summary, outputFilename)
#   }
# }
