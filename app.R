library(taxize)
library(shiny)
source("taxize_if.R")

# Define UI ----
ui <- fluidPage(
  titlePanel("Welcome to Taxize"),
  
  
  sidebarLayout(
    sidebarPanel(
          textAreaInput(inputId = "names_list", "Text input", value="panthera", 
          placeholder = "Enter your scientific names here..."),
          #actionButton("upload_csv", "Upload CSV"),
          actionButton("fuzzy_lookup", "Resolve Names"),
          h3(""),
          h3(""),
          selectInput("data_sources", 
            "Data Sources to lookup", 
            choices = choicesDB,
            multiple=TRUE,
            selected = 1
          ),
          actionButton("db_lookup", "DB Lookup"),
          h3(""),
          actionButton("set_api_keys", "Set your API keys"),
          h3(""),
          conditionalPanel(condition = "input.set_api_keys == 0", 
                           selectInput("api_keys", "Provide API Key for DB ", c(choicesAPIKeys)),
                           textInput("api_key_value", "Enter the API Key here"),
                           actionButton("save_api_key", "Save Key to my Env")
          ),
          
    ),
    mainPanel(
        #h3("Results of Lookup"),
        tableOutput("results_lookup_table"),
        #h3("Resolved Names"),
        tableOutput("resolved_names"),
        
        actionButton("download_csv", "Download Results in CSV"),
     ),
  )
)

# Define server logic ----
server <- function(input, output) {
  ans = eventReactive(input$db_lookup, {
    
    species_names <- unlist(strsplit(input$names_list,"\n"))
    
    resolved_frames = gnr_resolve(name=species_names, 
                                  best_match_only = TRUE,
                                  canonical = TRUE,
                                  fields = 'all', # Get all data fields, we can trim down after
                      )
    print_resolved_names(resolvedframes = resolved_frames)
    master_lookup <- resolved_frames
    
    #for loop lookup for multiple DBs and collating
    for (i in as.integer(input$data_sources)) {
      #check if API key required, if yes, if available
      
      #searchFunction = match.fun(DBLookupFunctions[i])
      #cat(file=stderr(), " \nSelected source ", DBNames[i], "Lookup function = " , DBLookupFunctions[i], " \n")      
      
      #taxize call
      lookups <- do.call(DBLookupFunctions[i], list(resolved_frames$matched_name2, DBLookupArgs[i]))
      
      #the merge will be with a different column name for each search? using from csv file for now
      #tbd : rename columns in the merged list
      master_lookup = merge(master_lookup, lookups, by.x="matched_name2", by.y=DBLookpupTaxonColumn[i]) 
      
      results_filename <- paste("lookupresults", DBNames[i], ".csv", sep="_")
      cat(file=stderr(), " \nWriting results to file ", results_filename)
      write.csv(lookups, results_filename)
    }
    #tbd : update ans properly with selected columns from all csv files
    
    ans <- master_lookup
  })
  
  observeEvent(input$fuzzy_lookup , {
    species_names <- unlist(strsplit(input$names_list,"\n"))
    resolved_frames = gnr_resolve(name=species_names, 
                                  best_match_only = TRUE,
                                  canonical = TRUE,
                                  fields = 'all', # Get all data fields, we can trim down after
                                  )
    output$resolved_names <- renderTable({
      resolved_frames
    })
  })
  
  observeEvent(input$db_lookup, {
    output$results_lookup_table <- renderTable({ 
      ans()
    })
  })
  
  observeEvent(input$download_csv, {
    write.csv(data_frames, "resolvednames.csv") 
  })
  
  observeEvent(input$save_api_key, {
    #tbd: set this perm in the .Rprofile or something
    cat(file=stderr(), " \n api_keys = ", input$api_keys)
    env_var = DBsNeedingAPIKeysEnvVar[as.integer(input$api_keys)]
    cat(file=stderr(), "\nSetting env var", env_var, " with value ", input$api_key_value)
    Sys.setenv(env_var=input$api_key_value)
  })
}

print_resolved_names <- function(resolvedframes) {
  for (j in NROW(resolvedframes)) {
     cat(file=stderr(), " \nResolved names[", j, "] = ", resolvedframes$matched_name2[j])
  }
}


# Run the app ----
shinyApp(ui = ui, server = server)



