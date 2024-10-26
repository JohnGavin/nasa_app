library(shiny)
library(httr)
library(jsonlite)

# Define UI
ui <- fluidPage(
  titlePanel("NASA APOD Viewer"),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Select Date:", value = "2024-10-20")
    ),
    mainPanel(
      textOutput("title"),
      textOutput("explanation"),
      uiOutput("mediaOutput")
    )
  )
)

# Define server logic
server <- function(input, output) {
  observe({
    req(input$date)
    date_str <- format(input$date, "%Y-%m-%d")
    api_key <- "DEMO_KEY"  # Replace with your NASA API key
    url <- paste0("https://api.nasa.gov/planetary/apod?date=", date_str, "&api_key=", api_key)

    # Fetch the content from the API
    response <- GET(url)
    data <- fromJSON(content(response, "text", encoding = "UTF-8"))

    output$title <- renderText({ data$title })
    output$explanation <- renderText({ data$explanation })

    # Check the media type and render accordingly
    if (!is.null(data$media_type) && data$media_type == "image") {
      output$mediaOutput <- renderUI({
        tags$img(src = data$url, alt = "APOD Image", style = "max-width: 100%; height: auto;")
      })
    } else if (!is.null(data$media_type) && data$media_type == "video") {
      output$mediaOutput <- renderUI({
        tags$iframe(src = data$url, width = "100%", height = "500px", frameborder = "0", allowfullscreen = TRUE)
      })
    } else {
      output$mediaOutput <- renderUI({
        tags$p("Media not available")
      })
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
