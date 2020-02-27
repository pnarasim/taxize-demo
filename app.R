library(taxize)
library(shiny)
source("taxize_if.R")

# Define UI ----
ui <- fluidPage(
  titlePanel("Welcome to Taxize"),
  
  
  sidebarLayout(position = "left",
    sidebarPanel(
      width="12",
      fluidRow(
        column(4, 
          textAreaInput(inputId = "namesList", h3("Text input"), value="panthera", 
          placeholder = "Enter your scientific names here...")
        ),
        column(3,
          h3("Fuzzy Lookup"),
          actionButton("fuzzyLookup", "Resolve Names")
        ),
        column(5,
          radioButtons("dataSources", 
            h3("Data Sources to lookup"), 
            choiceNames = DBNames,
            choiceValues = DBIndexes,
            selected = 0
          )
        )
      ),
      fluidRow(
        column(3,
               h3("DB Lookup"),
               actionButton("dbLookup", "DB Lookup")
        )
      )
    ),
    mainPanel(
      width="7",
      fluidRow(
        h3("Results of Lookup"),
        tableOutput("lookupResultsTable")
      ),
      fluidRow(
        h3("Resolved Names"),
        tableOutput("resolvedNames")
      )
    ),
  )
)

# Define server logic ----
server <- function(input, output) {
    
  ans = eventReactive(input$dbLookup, {
    speciesNames <- unlist(strsplit(input$namesList,"\n"))
    #for loop if permitting lookup for multiple DBs and collating
    #for (i in input$dataSources) {
      cat(file=stderr(), " Selected source ", DBNames[as.integer(input$dataSources)], "Lookup function = " , DBLookupFunctions[as.integer(input$dataSources)], " \n")
      #check if API key required, if yes, if available
      searchFunction = match.fun(DBLookupFunctions[as.integer(input$dataSources)])
      #taxize call
      do.call(searchFunction, list(speciesNames))
    #}
  })
  
  observeEvent(input$fuzzyLookup , {
    speciesNames <- unlist(strsplit(input$namesList,"\n"))
    resolved_frames = gnr_resolve(name=speciesNames)
    output$resolvedNames <- renderTable({
      resolved_frames
    })
  })
  
  observeEvent(input$dbLookup, {
    output$lookupResultsTable <- renderTable({ 
      ans()
    })
  })
}

# Run the app ----
shinyApp(ui = ui, server = server)



