# selectData module #
selectDataUI <- function(id, label) {
  ns <- NS(id)

  tagList(
    selectInput(ns('selectType'), label,
                choices = c(''))
  )
}
selectDataServer <- function(id, inputData, myColumn, label) {
  moduleServer(
    id,
    function(input, output, session) {
      filteredData <- reactive({
        req(input$selectType)
        inputData()[eval(as.name(myColumn))==input$selectType,]
      })
      observe({
        updateSelectInput(session = session,
                          inputId = 'selectType',
                          label = label, # add label here too in v0.4.0 ?
                          choices=c('', unique(inputData(), 
                                               by=myColumn)[[myColumn]]
                          )
        )
      })
      return(filteredData)
    }
  )
}