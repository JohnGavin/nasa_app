library(shiny)
library(httr)
library(jsonlite)

# Define UI
ui <- fluidPage(
  titlePanel("NASA APOD Viewer"),
  tags$head(
    tags$style(HTML("
      .error { color: red; }
      .loading { display: none; }
      .loading.active { display: block; }
      img { max-width: 100%; height: auto; }
      .explanation { margin: 20px 0; }
    "))
  ),
  sidebarLayout(
    sidebarPanel(
      dateInput("date", "Select Date:", value = Sys.Date()),
      div(id = "loading", class = "loading", "Loading...")
    ),
    mainPanel(
      h3(textOutput("title")),
      div(class = "explanation", textOutput("explanation")),
      uiOutput("mediaOutput")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  getData <- reactive({
    req(input$date)
    date_str <- format(input$date, "%Y-%m-%d")
    api_key <- "DEMO_KEY"
    url <- paste0("https://api.nasa.gov/planetary/apod?date=", date_str, "&api_key=", api_key)

    tryCatch(
      {
        response <- GET(url)
        if (status_code(response) == 200) {
          fromJSON(content(response, "text", encoding = "UTF-8"))
        } else {
          list(
            title = "Error",
            explanation = "Failed to fetch data from NASA API",
            media_type = "error"
          )
        }
      },
      error = function(e) {
        list(
          title = "Error",
          explanation = paste("An error occurred:", e$message),
          media_type = "error"
        )
      }
    )
  })

  output$title <- renderText({
    getData()$title
  })

  output$explanation <- renderText({
    getData()$explanation
  })

  output$mediaOutput <- renderUI({
    data <- getData()

    if (data$media_type == "image") {
      tags$img(src = data$url, alt = data$title)
    } else if (data$media_type == "video") {
      tags$iframe(
        src = data$url,
        width = "100%",
        height = "500px",
        frameborder = "0",
        allowfullscreen = TRUE
      )
    } else {
      tags$p(class = "error", "Media not available")
    }
  })
}

# Create and return the Shiny app object
shinyApp(ui = ui, server = server)
