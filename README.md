# Research survey visitors analysis application, shinyapps.io deployment

## About

This is the shinyapps.io deployment of the thesis research survey analysis application for visitor data, developed for Sampo Vesanen's the University of Helsinki Master's Thesis *Parking private cars and spatial accessibility in Helsinki Capital Region – Parking time as a part of the total travel time*.

**View the application at: https://sampoves.shinyapps.io/visitors/**

View the Master's thesis data analysis workflow in this repository: https://github.com/sampoves/thesis-data-analysis

The thesis is available as PDF at the Digital Repository of the University of Helsinki: **http://urn.fi/URN:NBN:fi:hulib-202010304366**

## Application features

The application consists of two synchronised cumulative charts, which present 1) received survey responses and 2) first visits from an IP address to the survey application. The charts can be controlled by clicking and dragging the chart to zoom in on any time frame. The time frame can be controlled also from the general view located below the both charts. A doubleclick on the chart brings back the default views.

By default, the charts take 75 % of the screen width. This is satisfactory to most computer screens, but if on mobile, 100 % is probably the best. Use the slider with the text *plot width (% of screen)* to control the width of the charts.

For now, the best application user experience is attained **on desktop computers**, although some cursory testing has been done on Android operating systems.

This application was developed and tested in R for Windows 4.0.3. Essential software packages for this application were:

| Package | Version |
| --- | --- |
| Shiny | 1.5.0 |
| xts | 0.12.1 |
| dygraphs | 1.1.1.6 |
