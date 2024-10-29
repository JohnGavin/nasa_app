library(shiny)

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style("
      .title { margin-bottom: 20px; }
      .explanation { margin: 20px 0; }
      img { max-width: 100%; height: auto; }
      .error { color: red; }
      #loading { display: none; }
      .loading { display: block; }
    ")
  ),
  titlePanel(div(class = "title", "NASA Astronomy Picture of the Day")),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Select Date:",
        value = Sys.Date(),
        max = Sys.Date()
      ),
      textOutput("loadingText")
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
  # Reactive expression for loading state
  output$loadingText <- renderText({
    req(input$date)
    "Loading..."
  })

  # Reactive expression for API data
  nasa_data <- reactive({
    req(input$date)

    # Format date and create API URL
    date_str <- format(input$date, "%Y-%m-%d")
    api_key <- "DEMO_KEY" # Replace with your NASA API key
    url <- sprintf(
      "https://api.nasa.gov/planetary/apod?date=%s&api_key=%s",
      date_str, api_key
    )

    # Simulate API request (since we can't use httr in WebAssembly)
    # In a real deployment, you would use proper error handling
    Sys.sleep(1) # Simulate network delay

    # Return mock data for demonstration
    list(
      title = "Sample APOD Image",
      explanation = "This is a sample explanation since we can't make actual API calls in WebAssembly.",
      media_type = "image",
      url = "https://apod.nasa.gov/apod/image/2401/NGC1566_Webb_960.jpg"
    )
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
