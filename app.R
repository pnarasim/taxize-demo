library(taxize)
library(shiny)
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
          actionButton("fuzzyLookup", "Resolve Names"),
        ),
        column(5,
          checkboxGroupInput("dataSources", 
            h3("Data Sources to lookup"), 
            choices = list("Barcode of Life" = 1, 
              "COL" = 2, 
              "TNRS" = 3),
            selected = 1
          )
        )
      ),
      fluidRow(
        column(3,
               h3("DB Lookup"),
               actionButton("dbLookup", "DB Lookup"),
        )
      )
    ),
    mainPanel(
      width="7",
      tableOutput("lookupResultsTable")
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  ans = eventReactive(input$dbLookup, {
    names <- unlist(strsplit(input$namesList,"\n"))
    #taxize call
    cat(file=stderr(), "input list is ", names, "\n")
    bold_search(name=names, fuzzy=TRUE)
  })
  observeEvent(input$dbLookup, {
    output$lookupResultsTable <- renderTable({ 
      ans()
    })
  })
}

# Run the app ----
shinyApp(ui = ui, server = server)



