#------------------------------------------------------------------#
#
# Code Contribution in the beginning and later
#
# * run `03_code_contribution_ratios.R` first
#
#------------------------------------------------------------------#
# Author: Philipp Staender (philipp.staender@rwth-aachen.de)       #
#------------------------------------------------------------------#

# Loading and preparing R
# reset environment
ls()
rm(list=ls(all=TRUE))
getwd()
setwd("/Users/philipp/masterthesis/")

# This includes some helper methods (e.g. latex export, pdf export ...)
source('r/include.R')
source('r/include_filtered_organizations.R')  # org will be available as global `organizations`
source('r/include_subsetvalues.R')
source('r/include_linear_regression_plots.R')

