library(shiny)
library(httr)
library(jsonlite)

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .loading { display: none; }
      .loading.active { display: block; }
    "))
  ),
  titlePanel("NASA APOD Viewer"),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Select Date:", value = Sys.Date()),
      tags$div(id = "loading", class = "loading", "Loading...")
    ),
    mainPanel(
      textOutput("title"),
      tags$br(),
      textOutput("explanation"),
      tags$br(),
      uiOutput("mediaOutput")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Reactive value to store API response
  apod_data <- reactiveVal(NULL)

  observe({
    req(input$date)
    date_str <- format(input$date, "%Y-%m-%d")
    api_key <- "DEMO_KEY" # Replace with your NASA API key
    url <- paste0("https://api.nasa.gov/planetary/apod?date=", date_str, "&api_key=", api_key)

    # Show loading indicator
    shinyjs::addClass("loading", "active")

    # Fetch the content from the API
    tryCatch({
      response <- GET(url)
      if (status_code(response) == 200) {
        data <- fromJSON(content(response, "text", encoding = "UTF-8"))
        apod_data(data)
      } else {
        apod_data(list(
          title = "Error",
          explanation = "Failed to fetch data from NASA API",
          media_type = "error"
        ))
      }
    }, error = function(e) {
      apod_data(list(
        title = "Error",
        explanation = paste("An error occurred:", e$message),
        media_type = "error"
      ))
    }, finally = {
      # Hide loading indicator
      shinyjs::removeClass("loading", "active")
    })
  })

  output$title <- renderText({
    req(apod_data())
    apod_data()$title
  })

  output$explanation <- renderText({
    req(apod_data())
    apod_data()$explanation
  })

  output$mediaOutput <- renderUI({
    req(apod_data())
    data <- apod_data()

    if (!is.null(data$media_type)) {
      if (data$media_type == "image") {
        tags$img(
          src = data$url,
          alt = "APOD Image",
          style = "max-width: 100%; height: auto;"
        )
      } else if (data$media_type == "video") {
        tags$iframe(
          src = data$url,
          width = "100%",
          height = "500px",
          frameborder = "0",
          allowfullscreen = TRUE
        )
      } else {
        tags$p("Media not available")
      }
    } else {
      tags$p("Media type not specified")
    }
  })
}

# Create the Shiny app object
app <- shinyApp(ui = ui, server = server)

# Only run the app if this script is being run directly
if (!exists("running_in_build")) {
  runApp(app, port = 3838, host = "0.0.0.0")
}
