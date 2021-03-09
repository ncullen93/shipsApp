server <- 
function(input, output, server) {

  # create selectData modules
  shipTypeData <- selectDataServer('shipTypeFilter', data, 'ship_type', 'Ship Type')
  shipNameData <- selectDataServer('shipNameFilter', shipTypeData, 'SHIPNAME', 'Ship Name')

  # load data (use data.table so filtering is super fast)
  data <- reactive({
    create_modal(modal(
      id = "simple-modal",
      header = h2("Welcome to the ShipTracker app!"),
      "What this app lacks in beauty, it makes up for in speed and modularity."
    ))

    data <- data.table::fread('data/ships.csv')
    setkey(data, 'ship_type')
    setkey(data, 'SHIPNAME')

    hide_modal('simple-modal')
    return(data)
  })

  # calculate distance between each pair of points and also get max distance
  longestDistance <- reactive({
    req(shipNameData())

    distData <- shipNameData()

    # this seems to be faster than normal sapply() + which.max()
    maxVal <- maxRow <- -1
    distData$DIST <- c(
      sapply(1:(nrow(distData)-1), function(idx) {
        val <- geosphere::distm(distData[idx, c('LON','LAT')], distData[idx+1, c('LON','LAT')])
        if (val > maxVal) {
          maxVal <<- val
          maxRow <<- idx
          }
        val
        }), 0)

    # get two rows associated with the longest distance
    distData <- distData[c(maxRow, maxRow+1),]

    return(distData)
  })

  # render the special message about the max distance travelled
  output$longestDistanceText <- renderText({
    req(shipNameData())

    tmp_df2 <- longestDistance()
    maxDist <- sprintf('%.1f',tmp_df2[1,'DIST'])

    startLON <- sprintf('%.2f', tmp_df2$LON[1])
    endLON   <- sprintf('%.2f', tmp_df2$LON[2])
    startLAT <- sprintf('%.2f', tmp_df2$LAT[1])
    endLAT   <- sprintf('%.2f', tmp_df2$LAT[2])

    return(glue('This ship travelled a max distance of {maxDist} meters',
                ' between consecutive observations',
                ' - from ({startLON}, {startLAT}) to ({endLON}, {endLAT}).'))
  })

  # render the leaflet map showing the max distance travelled segment
  output$longestDistanceMap <- renderLeaflet({

    distData <- longestDistance()

    leaflet() %>%
      addTiles() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)) %>%
      setView(lng = distData$LON[1], lat = distData$LAT[1],
              zoom = 8) %>%
      addMarkers(data = distData[,c('LON','LAT')],
                 label=c('Start Point','Stop Point'),
                 popup = paste0(
                   "<strong>Longitude: </strong>", distData$LON, "<br>",
                   "<strong>Latitude: </strong>", distData$LAT, "<br>"
                 ),
                 icon=c(icon('ship'), icon('ship'))) %>%
      addPolylines(lng = distData$LON,
                   lat = distData$LAT,
                   color = 'black')
  })

  output$extraOptionsUI <- renderUI({

    # here is where I would add extra options
    if (input$showExtraOptions) {
      vertical_layout(
        'NOTE: These dont work.',
        br(),
        sliderInput('extraFilter', 'Filter by Date',
                    min=0, max=1,value=0.5),
        selectInput('shipTypeSubset', 'Include only the following ship types:',
                    choices=c(''), multiple=T)
      )
    } else {
      return()
    }

  })
}