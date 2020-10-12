
# Sampo Vesanen's Master's thesis statistical tests and visualisation
#####################################################################

# "Parking of private cars and spatial accessibility in Helsinki Capital Region"
# by Sampo Vesanen
# 13.10.2020
#
# This is an interactive tool for analysing the timeline of the results and
# visitors of my research survey.


# Libraries
library(shiny)
library(shinyjs)
library(tidyr)
library(dplyr)
library(dygraphs)
library(xts)
library(htmltools)

# App version
app_v <- "13.10.2020"


#### Preparation ####

# Important directories
datapath <- "appdata/records_for_r.csv"
visitorpath <- "appdata/visitors_for_r.csv"

# Read in csv data. Define column types
thesisdata <- read.csv(file = datapath,
                       header = TRUE, 
                       sep = ",",
                       colClasses = c(timestamp = "POSIXct", 
                                      zipcode = "character", 
                                      ip = "character", 
                                      timeofday = "factor", 
                                      parkspot = "factor", 
                                      likert = "factor", 
                                      artificial_vals = "numeric",
                                      artificial = "factor", 
                                      ykr_zone_vals = "numeric",
                                      ykr_zone = "factor", 
                                      subdiv = "factor"),
                       stringsAsFactors = TRUE)

# Name factor levels. Determine order of factor levels for plotting
levels(thesisdata$parkspot) <- list("On the side of street" = 1,
                                    "Parking lot" = 2,
                                    "Parking garage" = 3,
                                    "Private or reserved" = 4,
                                    "Other" = 5)

levels(thesisdata$likert) <- list("Extremely familiar" = 1,
                                  "Moderately familiar" = 2,
                                  "Somewhat familiar" = 3,
                                  "Slightly familiar" = 4,
                                  "Not at all familiar" = 5)

levels(thesisdata$timeofday) <- list("Weekday, rush hour" = 1,
                                     "Weekday, other than rush hour" = 2,
                                     "Weekend" = 3,
                                     "Can't specify, no usual time" = 4)

# SYKE does not provide official translations for these zones
levels(thesisdata$ykr_zone) <- list("keskustan jalankulkuvyohyke" = 1,
                                    "keskustan reunavyohyke" = 2,
                                    "alakeskuksen jalankulkuvyohyke" = 3,
                                    "intensiivinen joukkoliikennevyohyke" = 4,
                                    "joukkoliikennevyohyke" = 5,
                                    "autovyohyke" = 6,
                                    "novalue" = 7)

levels(thesisdata$artificial) <- list("Fully built" = 1,
                                      "Predominantly built" = 2,
                                      "Moderately built" = 3,
                                      "Some built" = 4,
                                      "Scarcely built" = 5)



#### Visitor ShinyApp ----------------------------------------------------------

# Use this ShinyApp to explore the development in amounts of survey respondents.

visitordata <- read.csv(file = visitorpath,
                        header = TRUE, 
                        sep = ",",
                        colClasses = c(X = "integer", id = "integer", 
                                       ip = "factor", ts_first = "POSIXct", 
                                       ts_latest = "POSIXct", count = "integer"),
                        stringsAsFactors = TRUE)

# The survey visitors table saved visitor timestamps as NOW() and that is UTC in 
# MySQL. Change POSIXct object timezone to UTC+3, Helsinki summer time
visitordata$ts_first <- visitordata$ts_first + 3 * 60 * 60
visitordata$ts_latest <- visitordata$ts_latest + 3 * 60 * 60

# First sort by timestamp, then rename X or id. This fixes responses with 
# multiple zipcodes. These records have the exact same timestamps and that proved 
# tricky for dygraph to understand
thesisdata_for_xts <- thesisdata[order(thesisdata$timestamp, decreasing = FALSE), ]
thesisdata_for_xts$X <- seq(1:length(thesisdata_for_xts$X))

# Create xts objects necessary to use dygraph
visitor_xts <- xts(x = visitordata$X, order.by = visitordata$ts_first)
records_xts <- xts(x = thesisdata_for_xts$X, 
                   order.by = thesisdata_for_xts$timestamp)



#### Dygraph event timestamps #### 
# These are manually collected from my email correspondence and Facebook history. 
# If many areas are in the same variable, the earliest timestamp is selected

# Twitter: @Digigeolab, @AccessibilityRG
twitter <- as.POSIXct("2019-05-07 10:43:00 EEST") 

# Maantieteen opiskelijat student organisation email list
mao <- as.POSIXct("2019-05-09 13:24:00 EEST") 

# Student email list: Vasara, Resonanssi, Matrix, Geysir, Synop, Meridiaani, 
# Tyyppi-arvo, HYK, TKO-ALY, Symbioosi, Helix, MYY, Sampsa, MYO, Lipidi,
# Vuorovaikeutus, YFK, Oikos
emails <- as.POSIXct("2019-05-14 10:58:00 EEST") 

# Lisaa kaupunkia Helsinkiin group and own Facebook wall. Also six private
# WhatsApp groups
fb <- as.POSIXct("2019-05-15 10:33:00 EEST") 

# Facebook neighborhood group advertisement begins:
# Haukilahti/Westend asukkaat, Pohjois-Espoon asukasfoorumi, Lippajarvi, 
# Matinkyla/Olari, Leppavaara, Soukka-Soko, Suur-Espoonlahti, Puskaradio Tapiola,
# Puskaradio Kauniainen/Grankulla, Enemman Tapiolaa!, Kivenlahden ystavat
espoo1 <- as.POSIXct("2019-05-22 18:00:00 EEST") 

# Kalasatama-Fiskehamnen, Sornainen, Punavuori, Laajasalo, Herttoniemi, 
# Mankkaan lapsiperheet, 
misc1 <- as.POSIXct("2019-05-23 21:11:00 EEST") 

# Oulunkyla kierrattaa ja keskustelee, Kapyla Helsinki, Kumpula, Arabian alue,
# Vallilan ja Hermannin alue, Hermanni-liike, Jatkasaari-liike, Ruoholahti asuu,
# Pasila Bole, Pasila-liike, Ruskeasuo, Meilahden kyla, Toolo-liike, Toolo-
# Seura ry
helsinki1 <- as.POSIXct("2019-05-24 16:28:00 EEST") 

# Pihlajamaki, Malmi, Pukinmaen foorumi, Viikki ja Latokartano ymparistoineen,
# Kuninkaantammi, Maununneva-Hakuninmaa, Kannelmaki-liike, Lauttasaari, 
# Munkkivuori, Niemenmaki, Etela-Haaga, Haagan ilmoitustaulu
helsinki2 <- as.POSIXct("2019-05-25 14:56:00 EEST") 

# Ostersundom, Aurinkolahti, Vuosaari, Kruunuvuorenranta, Kontula, Mellunmaki/
# Mellunkyla, Pitajanmaki, Munkkiniemi, ITA-HELSINKI, Itakeskus-itastadilaista
# laiffii, Marjaniemi Helsinki, Puotila & Vartsika, Vartiokyla/Vartioharju,
# Tammisalo, Herttoniemenranta, Roihuvuori, Kulosaari-HYGGE-Brando, Suutarilassa
# tapahtuu, Tapaninvainion foorumi, Tapanila-Mosabacka, Paloheina-Pakila-
# Torpparinmaki ilmoittaa (se aito ja alkuperainen)
helsinki3 <- as.POSIXct("2019-05-26 12:55:00 EEST") 

# Pitajanmakelaiset, Landbo, Kamppi-Punavuori-Hietalahti
helsinki4 <- as.POSIXct("2019-05-29 16:49:00 EEST") 

# Perusmaki Espoo, As Oy Helsingin Arabianrinne, Rajakyla Vantaa, Leppakorpi
# Vantaa, Korso, Rekola, Tikkurila, Aviapolis-asukkaiden alue, Kivisto,
# Kiviston suuralue, ASKISTO, Vantaanlaakson lapsiperheet, Vapaala, Pahkinarinne,
# Alppikyla, Laajalahti-ryhma (suljettu), Kilo Espoo, Karakallio, Saunalahti
# tapahtumat ja palvelut, Noykkio Espoo Foorumi, Henttaalaiset, Myyrmaki
misc2 <- as.POSIXct("2019-06-06 20:57:00 EEST") 

# Pohjois-Kirkkonummelaiset, Puskaradio Sipoo, Sibbo-Sipoo, Jarvenpaa, We <3
# Kerava, Lisaa kaupunkia Hyrylaan, Tuusula, Nurmijarvi, Nurmijarven
# viidakkorumpu, Vihtilaiset, Vihdin Nummela, Kirkkonummelaiset (sana vapaa)
peri <- as.POSIXct("2019-06-09 11:01:00 EEST") 

# Reminders to the largest Facebook groups: Vantaa Puskaradio, Sipoo-Sibbo, 
# Jarvenpaa, WE <3 KERAVA, Tuusula, Nurmijarven  viidakkorumpu, Vihtilaiset, 
# Korso, Kapyla Helsinki, Laajasalo, Vuosaari, ITA-HELSINKI, Lauttasaari, 
# Haagan ilmoitustaulu
reminder <- as.POSIXct("2019-06-26 15:33:00 EEST") 

# They only accepted to display my message in Nikinmaki and Puskaradio Espoo at
# this late date
nikinmaki <- as.POSIXct("2019-06-27 14:26:00 EEST")
puskaradioespoo <- as.POSIXct("2019-06-27 21:30:00 EEST")

# A reminder to Lisaa kaupunkia Helsinkiin
lisaakaupunkia2 <- as.POSIXct("2019-07-02 12:06:00 EEST")

# A reminder for email lists, all except MaO. A new ad to GIS-velhot FB group
misc3 <- as.POSIXct("2019-07-05 10:29:00 EEST")



# Shiny application
visitor_server <- function(input, output) {
  
  # Get the window width using JavaScript, then send to Shiny server
  shinyjs::runjs("setInterval(function() {
                    var wid = window.innerWidth;
                    Shiny.onInputChange('windowsize_h', wid);
                  }, 0);")

  # Reactively set the dygraph width
  thisWidth <- shiny::reactive({
    
    # Make 100 % plot width actually 95 %, prevent overflow
    if(input$width == 100) {
      result <- input$windowsize_h * 0.95
    } else {
      result <- input$windowsize_h * (input$width / 100)
    }
    result
  })
  
  output$dygraph <- renderUI({
    visitor_graph <- list(
      dygraph(records_xts, 
              main = "Received records", 
              group = "thesis",
              width = thisWidth()) %>%
        dyOptions(drawPoints = TRUE, 
                  pointSize = 2) %>%
        dyRangeSelector(height = 70) %>%
        
        dyEvent(twitter, "@Digigeolab, @AccessibilityRG", labelLoc = "bottom") %>%
        dyEvent(mao, "MaO email list") %>%
        dyEvent(emails, "Kumpula and Viikki student email lists") %>%
        dyEvent(fb, "Lisaa kaupunkia Helsinkiin, own Facebook wall and 6 WhatsApp groups") %>%
        dyEvent(espoo1, "Espoo, 11 groups") %>%
        dyEvent(misc1, "Espoo, Mankkaan lapsiperheet; Helsinki, 5 groups") %>%
        dyEvent(helsinki1, "Helsinki, 14 groups", labelLoc = "bottom") %>%
        dyEvent(helsinki2, "Helsinki, 12 groups", labelLoc = "bottom") %>%
        dyEvent(helsinki3, "Helsinki, 21 groups", labelLoc = "bottom") %>%
        dyEvent(helsinki4, "Helsinki, 3 groups", labelLoc = "bottom") %>%
        dyEvent(misc2, "Espoo, 7 groups; Vantaa, 13 groups; Helsinki, 2 groups", labelLoc = "bottom") %>%
        dyEvent(peri, "Surrounding municipalities, 12 groups", labelLoc = "bottom") %>%
        dyEvent(reminder, "Reminders, largest communities, 14 groups", labelLoc = "bottom") %>%
        dyEvent(nikinmaki, "Vantaa, Nikinmaki", labelLoc = "bottom") %>%
        dyEvent(puskaradioespoo, "Espoo, Puskaradio Espoo", labelLoc = "bottom") %>%
        dyEvent(lisaakaupunkia2, "Reminder, Lisaa kaupunkia Helsinkiin", labelLoc = "bottom") %>%
        dyEvent(misc3, "Email list reminders, GIS-velhot FB group", labelLoc = "bottom"),
      
      dygraph(visitor_xts, 
              main = "Unique first visits", 
              group = "thesis",
              width = thisWidth()) %>%
        dyOptions(drawPoints = TRUE, 
                  pointSize = 2) %>%
        dyRangeSelector(height = 70) %>%
        
        dyEvent(twitter, "@Digigeolab, @AccessibilityRG", labelLoc = "bottom") %>%
        dyEvent(mao, "MaO email list") %>%
        dyEvent(emails, "Kumpula and Viikki student email lists") %>%
        dyEvent(fb, "Lisaa kaupunkia Helsinkiin, own Facebook wall and 6 WhatsApp groups") %>%
        dyEvent(espoo1, "Espoo, 11 groups") %>%
        dyEvent(misc1, "Espoo, Mankkaan lapsiperheet; Helsinki, 5 groups") %>%
        dyEvent(helsinki1, "Helsinki, 14 groups", labelLoc = "bottom") %>%
        dyEvent(helsinki2, "Helsinki, 12 groups", labelLoc = "bottom") %>%
        dyEvent(helsinki3, "Helsinki, 21 groups", labelLoc = "bottom") %>%
        dyEvent(helsinki4, "Helsinki, 3 groups", labelLoc = "bottom") %>%
        dyEvent(misc2, "Espoo, 7 groups; Vantaa, 13 groups; Helsinki, 2 groups", labelLoc = "bottom") %>%
        dyEvent(peri, "Surrounding municipalities, 12 groups", labelLoc = "bottom") %>%
        dyEvent(reminder, "Reminders, largest communities, 14 groups", labelLoc = "bottom") %>%
        dyEvent(nikinmaki, "Vantaa, Nikinmaki", labelLoc = "bottom") %>%
        dyEvent(puskaradioespoo, "Espoo, Puskaradio Espoo", labelLoc = "bottom") %>%
        dyEvent(lisaakaupunkia2, "Reminder, Lisaa kaupunkia Helsinkiin", labelLoc = "bottom") %>%
        dyEvent(misc3, "Email list reminders, GIS-velhot FB group", labelLoc = "bottom"))
    
    browsable(tagList(visitor_graph))
  })
}

visitor_ui <- fillPage(
  shinyjs::useShinyjs(),
  
  # CSS tricks. Most importantly create white background box for the dygraph
  # and center it. In centering, parent and child element are essential and
  # their text-align: center; and display: inline-block; parameters.
  tags$head(
    tags$style(HTML("
      html, body {
        width: 100%;
        text-align: center;
        background-color: #272b30;
      	height: 100%;
        scroll-behavior: smooth;
        overflow: auto;
        overscroll-behavior: contain; /*disable pull-down-to-refresh on Chrome*/
      }
      h2, p {
        color: #c8c8c8;
      }
      .contentsp {
        text-align: center;
        display: inline-block;
      }
      .contentsc {
        border: 5px solid #2e3338;
        border-radius: 10px;
        padding: 12px;
        margin-top: 15px;
        background: white;
        text-align: center;
      }
      .shiny-input-container {
        margin: auto;
      }
      #version-info {
        font-size: 11px;
        color: grey;
        margin-top: 5px;
      }
      #dygraph {
        display: inline-block;
      }"
    ))
  ),
  
  titlePanel("Sampo Vesanen MSc thesis research survey: received responses",
             "and survey page first visits"),
  p("Click and hold, then drag and release to zoom to a period of time. Double",
    "click to return to the full view."),
  HTML("<div class='contentsp'>",
       "<div class='contentsc'>"),
  
  sliderInput(
    inputId = "width",
    label = HTML("plot width (% of screen)"),
    min = 25,
    max = 100,
    value = 75,
    step = 25),

  uiOutput("dygraph"),
  HTML("</div>",
       "</div>"),
  HTML(paste("<p id='version-info'>Visitors analysis application version", 
             app_v, "</p>"))
)
shinyApp(visitor_ui, visitor_server)