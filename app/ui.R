ui <- 
semanticPage(
  sidebar_layout(
    sidebar_panel(
      vertical_layout(
        h2(style = 'text-align: center;',
           icon("ship"), 'ShipTracker'),
        br(),
        selectDataUI('shipTypeFilter', 'Ship Type'),
        selectDataUI('shipNameFilter', 'Ship Name'),
        hr(),
        textOutput('longestDistanceText'),
        hr(),
        checkbox_input('showExtraOptions', 'Show Extra Options',
                        type='toggle', is_marked=FALSE),
        uiOutput('extraOptionsUI'),
        cell_args = "padding: 10px; width: 100%;"
      )
    ),
    main_panel(
      leafletOutput('longestDistanceMap',
                    height = '100vh')
    ),
    min_height = "100vh",
    mirrored = FALSE,
    container_style = "background-color: white; gap: 0;",
    area_styles = list(
      sidebar_panel = "
          border-radius: 0;
          padding: 25px;
        "
    )
  )
)