# Set number of samples
n = 1e2

# Define server logic for app
server <- function(input, output) {
  # Sample data
  y = reactive(
    switch (
      input$rv,
      "Poisson" = rpois(1e3, lambda = 2),
      "Bernoulli" = rbinom(1e3, 1, 0.5),
      "Normal" = rnorm(1e3, 5)
    )
  )
  
  # Plot data
  output$scatterPlot <- renderPlot({
    switch (
      input$rv,
      "Poisson" = barplot(table(y())),
      "Bernoulli" = barplot(table(y())),
      "Normal" = hist(y(), main = "", xlab = "", ylab = "")
    )
    title(main = "Data", ylab = "Count", xlab = "Value")
  })
  
  # Plot negative log-likelihood surface
  output$NLLPlot <- renderPlot({
    # Define NLL function
    nll = switch (
      input$rv,
      "Poisson" = function(y, lambda) -sum(dpois(y(), lambda, log = T)),
      "Bernoulli" = function(y, p) -sum(dbinom(y(), 1, p, log = T)),
      "Normal" = function(y, mu) -sum(dnorm(y(), mu, log = T))
    )
    
    # Create grid of parameter values and vector for NLL values
    nll_grid = par_grid = switch (
      input$rv,
      "Poisson" = seq(1, 3, 0.1),
      "Bernoulli" = seq(0, 1, 0.1),
      "Normal" = seq(4, 6, 0.1)
    )
    
    # Find NLL over grid of parameter values
    for (i in seq_along(nll_grid)) {
      nll_grid[i] = nll(y(), par_grid[i])
    }
    
    # Set parameter name for plot
    par_name = switch(
      input$rv,
      "Poisson" = "Rate",
      "Bernoulli" = "Probability",
      "Normal" = "Mean"
    )

    # Plot NLL
    plot(par_grid, nll_grid, main = "Negative log-likelihood", xlab = par_name, 
         ylab = "NLL", type = 'l')
    
  })
}