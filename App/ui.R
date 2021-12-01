library(shiny)

# Define UI for app
ui <- fluidPage(
  # App title
  titlePanel("Maximum likelihood estimation"),
  
  p("This is a little web app in Shiny to illustrate maximum likelihood
  estimation via simulation. It generates samples from a Bernoulli, 
  Poisson, or Normal random variable.  It takes a single parameter as 
  input, and shows the value counts and negative log-likelihood for the 
  first sample, and the MLEs, confidence intervals, and CI coverage over
    all samples."),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      # Tabset panel for variable types
      tabsetPanel(
        id = "rv",
        tabPanel(
          title = "Bernoulli",
          sliderInput(inputId = "p", label = "Probability:",
                      min_p, max_p, value = 0.5, step = step_p)
        ),
        tabPanel(
          title = "Poisson",
          sliderInput(inputId = "lambda", label = "Rate:",
                      min_lambda, max_lambda, value = 0.5, step = step_lambda)
        ),
        tabPanel(
          title = "Normal",
          sliderInput(inputId = "mu", label = "Probability:",
                      min_mu, max_mu, value = 0, step = step_mu)
        )
      )
    ),
    
    # Main panel for displaying outputs
    mainPanel(
      # Head of first sample
      h4("Head of first sample"),
      tableOutput(outputId = "dataHead"),
      
      # Scatterplot
      plotOutput(outputId = "scatterPlot"),
      
      # NLL plot
      plotOutput(outputId = "NLLPlot"),
      
      # MLEs plot
      plotOutput(outputId = "MLEplot"),
      
      # CI plot
      plotOutput(outputId = "CIPlot"),
      
      # CI coverage
      textOutput(outputId = "ciCov")
    )
  )
)
