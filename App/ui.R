library(shiny)

# Define UI for app
ui <- fluidPage(
  # App title
  titlePanel("Maximum likelihood"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      # Selector for variable type
      selectInput(inputId = "rv", label = "Variable type:",
                  choices = c("Bernoulli", "Poisson", "Normal"))
      
      # # Slider for the Standard deviation
      # sliderInput(inputId = "b", label = "Intercept:",
      #             min = min_sig, max = max_sig, value = 1.5, step = step, 
      #             animate = animationOptions(int = 2000))
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      # Head of first sample
      tableOutput(outputId = "dataHead"),
      
      # Scatterplot
      plotOutput(outputId = "scatterPlot"),
      
      # NLL plot
      plotOutput(outputId = "NLLPlot"),
      
      # MLEs plot
      plotOutput(outputId = "MLEplot"),
      
      # CI plot
      plotOutput(outputId = "CIPlot")
    )
  )
)