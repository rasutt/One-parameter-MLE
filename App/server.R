# Set sample size and number of samples
n = 1e2
n_samps = 1e2

# Define server logic for app
server <- function(input, output) {
  true_val = reactive(
    switch(
      input$rv,
      "Bernoulli" = input$p,
      "Poisson" = input$lambda,
      "Normal" = input$mu,
    )
  )
  
  # Sample data
  y = reactive(
    switch (
      input$rv,
      "Bernoulli" = matrix(rbinom(n * n_samps, 1, true_val()), n, n_samps),
      "Poisson" = matrix(rpois(n * n_samps, true_val()), n, n_samps),
      "Normal" = matrix(rnorm(n * n_samps, true_val()), n, n_samps),
    )
  )
  
  # Print head of first sample
  output$dataHead <- renderTable(head(data.frame(Data = y()[, 1])))
  
  # Plot first sample
  output$scatterPlot <- renderPlot({
    switch (
      input$rv,
      "Bernoulli" = barplot(table(y()[, 1])),
      "Poisson" = barplot(table(y()[, 1])),
      "Normal" = hist(y()[, 1], main = "", xlab = "", ylab = "")
    )
    title(main = "Value counts for first sample", ylab = "Count", 
          xlab = "Value")
  })
  
  # Set parameter name for plot
  par_name = reactive(switch(
    input$rv,
    "Bernoulli" = "Probability",
    "Poisson" = "Rate",
    "Normal" = "Mean"
  ))
  
  # Plot negative log-likelihood surface for first sample
  output$NLLPlot <- renderPlot({
    # Define NLL function
    nll = switch (
      input$rv,
      "Bernoulli" = function(y, p) -sum(dbinom(y, 1, p, log = T)),
      "Poisson" = function(y, lambda) -sum(dpois(y, lambda, log = T)),
      "Normal" = function(y, mu) -sum(dnorm(y, mu, log = T))
    )
    
    # Create grid of parameter values and vector for NLL values
    nll_grid = par_grid = switch (
      input$rv,
      "Bernoulli" = seq(min_p, max_p, step_p),
      "Poisson" = seq(min_lambda, max_lambda, step_lambda),
      "Normal" = seq(min_mu, max_mu, step_mu)
    )
    
    # Find NLL over grid of parameter values
    for (i in seq_along(nll_grid)) {
      nll_grid[i] = nll(y()[, 1], par_grid[i])
    }
    
    # Plot NLL
    plot(
      par_grid, nll_grid, 
      main = "Negative log-likelihood and confidence interval for first sample", 
      xlab = par_name(), ylab = "NLL", type = 'l'
    )
    abline(v = true_val(), col = 2)
    abline(v = mles()[1], col = 4)
    abline(v = cis()[1, 1], col = 4, lty = 2)
    abline(v = cis()[2, 1], col = 4, lty = 2)
  })
  
  # Find maximum likelihood estimates and confidence intervals
  mles = reactive(colMeans(y()))
  cis = reactive({
    var_est = switch (
      input$rv,
      "Bernoulli" = mles() * (1 - mles()),
      "Poisson" = mles(),
      "Normal" = apply(y(), 2, var)
    )
    rbind(mles(), mles()) + c(-1, 1) * 1.96 * 
      sqrt(matrix(var_est, 2, n_samps, T) / n)
  })
  
  # Plot MLEs
  output$MLEplot = renderPlot({
    boxplot(mles(), main = "Maximum likelihood estimates for all samples", 
            ylab = par_name())
    abline(h = true_val(), col = 2)
  })
  
  # Check CI coverage
  ci_cov = reactive((true_val() > cis()[1, ]) & (true_val() < cis()[2, ]))
  
  # Plot confidence intervals
  output$CIPlot = renderPlot({
    plot(rep(1:n, 2), cis(), main = "Confidence intervals for all samples",
         ylab = par_name(), xlab = "Sample", type = 'n')
    arrows(1:n, cis()[1, ], 1:n, cis()[2, ], code = 3, length = 0.02, 
           angle = 90, 
           lwd = 1 + !ci_cov())
    abline(h = true_val(), col = 2)
  })
  
  # Print CI coverage
  output$ciCov = renderText(
    paste("Confidence interval coverage over all samples:", mean(ci_cov()))
  )
}