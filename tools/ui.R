
shinyUI(pageWithSidebar(
  
  ##########################################
  # STEP 1: The name of the application
  
  headerPanel("S&P 500 Daily Returns App"),
  
  ##########################################
  # STEP 2: The left menu, which reads the data as
  # well as all the inputs exactly like the inputs in RunStudy.R
  
  sidebarPanel(
    
    HTML("<center><h4>Please first read the notes below</h4>"),
    HTML("<hr>"),    
    
    ###########################################################    
    # STEP 2.1: read the data
    
    HTML("<center><h3>Data Upload </h3></center>"),
    HTML("<br>"),
    HTML("Choose a pre-loaded file (Recommended for Testing the App):"),    
    selectInput('datafile_name_coded', '',
                c("Financial Sector Stocks", "Tech Sector Stocks", "All Stocks  (slow...)"),multiple = FALSE),
    HTML("<hr>"),
    HTML("<hr>"),
    checkboxInput("load_choice", "Load your own data (requires fast internet connection)"),
    HTML("<br>"),
    fileInput('datafile_name', ''),
    HTML("<hr>"),
    
    ###########################################################
    # STEP 2.2: read the INPUTS. 
    # THESE ARE THE *SAME* INPUT PARAMETERS AS IN THE RunStudy.R
    
    numericInput("start_date", "Select Starting date (use the arrows or type a number from 1 to the number of days):", 1),
    numericInput("end_date", "Select End date (more than starting date, less than total number of dates):", 2586),
    numericInput("numb_components_used", "Select the number of PCA risk factors (between 1 and the total number of stocks):", 3),
    
    ###########################################################
    # STEP 2.3: buttons to download the new report and new slides 
    
    HTML("<hr>"),
    HTML("<h4>Download the new HTML report </h4>"),
    downloadButton('report', label = "Download"),
    HTML("<hr>"),
    HTML("<h4>Download the new HTML5 slides </h4>"),
    downloadButton('slide', label = "Download"),
    HTML("<hr>"),
    
    HTML("<h4>Notes:</h4>"),
    HTML("<br>"),    
    HTML("If you load a data file, it should be a <strong>.csv file in the format of the case with the columns being the stock/asset returns and the rows the days/time periods, with the first row being the dates
         in format `2003-01-03` and the first column being the names of the stocks e.g. `AMD` </strong>"),    
    HTML("<br>"),    
    HTML("<br>"),    
    HTML("If you load your own data you need to keep the selection of the `Load your data` button above on. Otherwise, to use the pre-loaded data you must unselect that button"),    
    HTML("<br>"),    
    HTML("<br>"),    
    HTML("Please reload the web page any time the app crashes. <strong> When it crashes the screen turns into grey.</strong> If it only stops reacting it may be because of 
heavy computation or traffic on the server, in which case you should simply wait. This is a test version.</center>"),    
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
                   numericInput("stock_order", "Select the stock to plot (e.g. 1 is the best, 2 is second best, etc):", 1),
                   tags$hr(),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   tags$hr(),
                   div(class="span12",h4("Returns of the Stock")),
                   tags$hr(),
                   div(class="span12",h4("Cumulative Returns")),
                   div(class="span6",plotOutput('chosen_stock')), 
                   tags$hr(),
                   div(class="span12",h4("Monthly/Yearly Returns")),                   
                   div(class="span6",tableOutput("chosen_stock_pnl_matrix"))                   
               )
      ),               
      
      tabPanel("Single Stocks",
               div(class="row-fluid",
                   div(class="span12",h4("Select Stock")),
                   textInput("ind_stock", "Select the ticker of the stock to show (use capital letters e.g. AAPL):", "AAPL"),
                   tags$hr(),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   tags$hr(),
                   div(class="span12",h4("Cumulative Returns of Selected Stock")),
                   div(class="span6",plotOutput('stock_returns')), 
                   tags$hr(),
                   div(class="span12",h4("Monthly/Yearly Returns of Selected Stock")),                   
                   div(class="span6",tableOutput("stock_pnl_matrix"))                   
               )
      ),
      
      tabPanel("Histogram", plotOutput('histogram')),
      
      tabPanel("The Market", 
               div(class="row-fluid",
                   div(class="span12",h4("The Equally Weighted Basket of all Stocks")),
                   tags$hr(),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   tags$hr(),
                   div(class="span12",h4("Cumulative Returns")),
                   div(class="span6",plotOutput('market')), 
                   tags$hr(),
                   div(class="span12",h4("Monthly/Yearly Returns")),                   
                   div(class="span6",tableOutput("market_pnl_matrix"))                   
               )
      ),
      
      tabPanel("Market Mean Reversion", 
               div(class="row-fluid",
                   div(class="span12",h4("Mean Reversion Strategy of Equal Weighted Basket of all Stocks")),
                   tags$hr(),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   tags$hr(),
                   div(class="span12",h4("Cumulative Returns")),
                   div(class="span6",plotOutput('mr_strategy')), 
                   tags$hr(),
                   div(class="span12",h4("Monthly/Yearly Returns")),                   
                   div(class="span6",tableOutput("mr_strategy_pnl_matrix"))                   
               )
      ),               
      
      
      tabPanel("Negative Market Mean Reversion", 
               div(class="row-fluid",
                   div(class="span12",h4("Mean Reversion Strategy of Equal Weighted Basket of all Stocks only days after the market dropped")),
                   tags$hr(),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   tags$hr(),
                   div(class="span12",h4("Cumulative Returns")),
                   div(class="span6",plotOutput('both_markets')), 
                   tags$hr(),
                   div(class="span12",h4("Monthly/Yearly Returns")),                   
                   div(class="span6",tableOutput("both_markets_pnl_matrix"))                   
               )
      ),               
      
      tabPanel("Eigenvalues Plot", plotOutput("eigen_plot")),
      
      tabPanel("Eigenvector Returns",                
               div(class="row-fluid",
                   numericInput("vector_plotted", "Select the eigenvector to plot (e.g.1):", 1),
                   tags$hr(),
                   div(class="span12",h5("NOTE: All returns reported correspond to returns if 1 dollar is invested every day from-close-to-close. No transaction costs included.")),
                   tags$hr(),
                   div(class="span12",h4("Returns of Selected Eigenvector")),
                   tags$hr(),
                   div(class="span12",h4("Cumulative Returns")),
                   div(class="span6",plotOutput('eigen_returns')), 
                   tags$hr(),
                   div(class="span12",h4("Monthly/Yearly Returns")),                   
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