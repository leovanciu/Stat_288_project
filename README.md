# Old tools for new problems: Integrating uncertainty from PM2.5 satellite imagery predictions with Bayesian hierarchical modeling
This repository contains the code used to generate the analysis and plots for my final project for Stat 288 "Old tools for new problems: Integrating uncertainty from PM2.5 satellite imagery predictions with Bayesian hierarchical modeling."

The analysis is not reproducible due to the confidential nature of the Medicare data, which can be acquired with a Data Usage Agreement. See https://github.com/NSAPH-Projects/National-Causal-Analysis for details on how this data is processed.

The ensemble model estimates of PM2.5 and the monitoring station measurements from the EPA are publicly available. The EPA measurements are directly obtained in Data_processing.R and the ensemble model estimates can be downloaded from https://sedac.ciesin.columbia.edu/data/set/aqdh-pm2-5-o3-no2-concentrations-zipcode-contiguous-us-2000-2016.

The files should be run in the following order:
1) Data_processing.R
2) Phase_2.R
3) Phase_3.R
4) Plots.R

Data_processing.R outputs two files, pm_monitor.csv which includes the annual monitored PM2.5 levels from EPA stations, and deaths_shp.rds which combines the ensemble model estimates with mortality data from Medicare and covariates from the American Community Survey and Darthmouth Atlas of Healthcare at the ZIP code level (not reproducible).

Phase_2.R runs the spatial regression model to estimate PM2.5 mean and uncertainty.

Phase_3.R runs the Stan models for mortality in Massachusets. 

Plots.R produces the figures in the paper.