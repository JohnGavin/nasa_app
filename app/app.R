library(shiny)
library(httr)
library(jsonlite)

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style("
      .title { margin-bottom: 20px; }
      .explanation { margin: 20px 0; }
      img { max-width: 100%; height: auto; }
      .error { color: red; }
      #loading { display: none; }
      #loading.active { display: block; }
    ")
  ),
  titlePanel(div(class = "title", "NASA Astronomy Picture of the Day")),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Select Date:",
        value = Sys.Date(),
        max = Sys.Date()
      ),
      div(id = "loading", "Loading...")
    ),
    mainPanel(
      div(
        class = "content",
        h3(textOutput("title")),
        div(
          class = "explanation",
          textOutput("explanation")
        ),
        uiOutput("mediaOutput")
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Reactive expression for API data
  nasa_data <- reactive({
    req(input$date)

    # Show loading state
    shinyjs::runjs("document.getElementById('loading').classList.add('active')")

    # Format date and create API URL
    date_str <- format(input$date, "%Y-%m-%d")
    api_key <- "DEMO_KEY" # Replace with your NASA API key
    url <- sprintf(
      "https://api.nasa.gov/planetary/apod?date=%s&api_key=%s",
      date_str, api_key
    )

    # Make API request with error handling
    result <- tryCatch(
      {
        response <- GET(url)
        if (status_code(response) == 200) {
          fromJSON(rawToChar(response$content))
        } else {
          list(
            title = "Error",
            explanation = sprintf("API Error: Status code %d", status_code(response)),
            media_type = "error"
          )
        }
      },
      error = function(e) {
        list(
          title = "Error",
          explanation = sprintf("Failed to fetch data: %s", e$message),
          media_type = "error"
        )
      }
    )

    # Hide loading state
    shinyjs::runjs("document.getElementById('loading').classList.remove('active')")

    result
  })

  # Render title
  output$title <- renderText({
    nasa_data()$title
  })

  # Render explanation
  output$explanation <- renderText({
    nasa_data()$explanation
  })

  # Render media (image or video)
  output$mediaOutput <- renderUI({
    data <- nasa_data()

    if (!is.null(data$media_type)) {
      if (data$media_type == "image") {
        tags$img(
          src = data$url,
          alt = data$title
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
        tags$p(
          class = "error",
          "Media not available"
        )
      }
    } else {
      tags$p(
        class = "error",
        "No media type specified"
      )
    }
  })
}

# Create Shiny app
shinyApp(ui = ui, server = server)
