
shinyUI(pageWithSidebar(
  
  ##########################################
  # STEP 1: The name of the application
  
  headerPanel("S&P 500 Daily Returns App"),
  
  ##########################################
  # STEP 2: The left menu, which reads the data as
  # well as all the inputs exactly like the inputs in RunStudy.R
  
  sidebarPanel(
    
    HTML("Please reload the web page any time the app crashes. <strong> When it crashes the screen turns into grey.</strong> If it only stops reacting it may be because of 
heavy computation or traffic on the server, in which case you should simply wait. This is a test version.</center>"),    
    HTML("<hr>"),    
    
    ###########################################################    
    # STEP 2.1: read the data
    
    HTML("Choose a data file:"),    
    selectInput('datafile_name_coded', '',
                c("Financial Sector Stocks", "Tech Sector Stocks", "All Stocks  (slow...)"),multiple = FALSE),
    
    ###########################################################
    # STEP 2.2: read the INPUTS. 
    # THESE ARE THE *SAME* INPUT PARAMETERS AS IN THE RunStudy.R
    
    numericInput("start_date", "Select Starting date (use the arrows or type a number from 1 to 2586):", 1),
    numericInput("end_date", "Select End date (more than starting date, less than 2586):", 2586),
    numericInput("numb_components_used", "Select the number of PCA risk factors (between 1 and the total number of stocks):", 3),
    
    ###########################################################
    # STEP 2.3: buttons to download the new report and new slides 
    
    HTML("<hr>"),
    HTML("<h4>Download the new HTML report </h4>"),
    downloadButton('report', label = "Download"),
    HTML("<hr>"),
    HTML("<h4>Download the new HTML5 slides </h4>"),
    downloadButton('slide', label = "Download"),
    HTML("<hr>")    
  ),  
  ###########################################################
  # STEP 3: The output tabs (these follow more or less the 
  # order of the Rchunks in the report and slides)
  
  mainPanel(
    # Just set it up
    tags$style(type="text/css",
               ".shiny-output-error { visibility: hidden; }",
               ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    # Now these are the taps one by one. 
    # NOTE: each tab has a name that appears in the web app, as well as a
    # "variable" which has exactly the same name as the variables in the 
    # output$ part of code in the server.R file 
    # (e.g. tableOutput('parameters') corresponds to output$parameters in server.r)
    
    tabsetPanel(
      
      tabPanel("Parameters", 
               div(class="row-fluid",
                   div(class="span12",h5("Note: The returns generated may be different from the returns of, say, the S&P 500 index, as the universe of stocks/data used may be biased (e.g. survivorship bias). 
                                         All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   tags$hr(),
                   tags$hr(),
                   div(class="span12",h4("Summary of Key Parameters")),
                   tags$hr(),
                   tableOutput('parameters')
               )
      ),
      
      tabPanel("Ordered Stocks", 
               div(class="row-fluid",
                   selectInput("order_criterion", "Select the criterion used to order the stocks:", choices=c("returns","sharpe","drawdown"), selected="returns", multiple=FALSE),
                   numericInput("stock_order", "Select the stock to plot (e.g. 1 is the best in terms of the selected criterion during this period, 2 is second best, etc):", 1),
                   div(class="span12",h4("Cumulative Returns and Table of Returns (below)")),
                   div(class="span6",plotOutput('chosen_stock')), 
                   tags$hr(),
                   div(class="span6",tableOutput("chosen_stock_pnl_matrix"))                   
               )
      ),               
      
      tabPanel("Select Stock",
               div(class="row-fluid",
                   div(class="span12",h4("Select Stock")),
                   textInput("ind_stock", "Select the ticker of the stock to show (use capital letters e.g. AAPL):", "AAPL"),
                   div(class="span12",h4("Cumulative Returns and Table of Returns (Below) of Selected Stock")),
                   div(class="span6",plotOutput('stock_returns')), 
                   tags$hr(),
                   div(class="span6",tableOutput("stock_pnl_matrix"))                   
               )
      ),
      
      tabPanel("Histogram: All Stocks", plotOutput('histogram')),
      
      tabPanel("The Market", 
               div(class="row-fluid",
                   div(class="span12",h4("The Equally Weighted Basket of all Stocks")),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   div(class="span12",h4("Cumulative Returns and Table of Returns (below)")),
                   div(class="span6",plotOutput('market')), 
                   div(class="span6",tableOutput("market_pnl_matrix"))                   
               )
      ),

      tabPanel("Histogram: Market", plotOutput('histogram_market')),
      
      tabPanel("Market Mean Reversion", 
               div(class="row-fluid",
                   div(class="span12",h4("Mean Reversion Strategy of Equal Weighted Basket of all Stocks")),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   div(class="span12",h4("Cumulative Returns and Table of Returns (below)")),
                   div(class="span6",plotOutput('mr_strategy')), 
                   div(class="span6",tableOutput("mr_strategy_pnl_matrix"))                   
               )
      ),               
      
      
      tabPanel("Negative Market Mean Reversion", 
               div(class="row-fluid",
                   div(class="span12",h4("Mean Reversion Strategy of Equal Weighted Basket of all Stocks only days after the market dropped")),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   div(class="span12",h4("Cumulative Returns and Table of Returns (below)")),
                   div(class="span6",plotOutput('both_markets')), 
                   div(class="span6",tableOutput("both_markets_pnl_matrix"))                   
               )
      ),               
      
      tabPanel("Eigenvalues Plot", plotOutput("eigen_plot")),
      
      tabPanel("Eigenvector Returns",                
               div(class="row-fluid",
                   numericInput("vector_plotted", "Select the eigenvector to plot (e.g.1):", 1),
                   div(class="span12",h4("Cumulative Returns and Table of Returns (below)")),
                   div(class="span6",plotOutput('eigen_returns')), 
                   div(class="span6",tableOutput("eigen_strategy_pnl_matrix"))                   
               )
      ),               
      
      tabPanel("Ordered Residuals", 
               numericInput("residuals_order", "Select the stock to plot residuals portfolio for (e.g. 1 is the best, 2 is second best, etc):", 1),
               plotOutput('chosen_residual')),
      
      tabPanel("Residuals Market", plotOutput('res_market')),
      
      tabPanel("Residuals Hindsight Portfolio", plotOutput('res_hindsight')) 
      
    )
  )
))