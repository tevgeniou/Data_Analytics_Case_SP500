

if (!exists("local_directory")) {  
  local_directory <- "~/Data_Analytics_Case_SP500" 
  source(paste(local_directory,"R/library.R",sep="/"))
  source(paste(local_directory,"R/heatmapOutput.R",sep="/"))
} 


# load all files in the data directory to have them available locally
load(paste(local_directory,"data/FinancialsData",sep="/"))
FinancialsData <- ProjectData
load(paste(local_directory,"data/TechData",sep="/"))
TechData <- ProjectData
load(paste(local_directory,"data/DefaultData",sep="/"))
MarketData <- ProjectData

# To be able to upload data up to 30MB
options(shiny.maxRequestSize=30*1024^2)
options(rgl.useNULL=TRUE)
options(scipen = 50)

shinyServer(function(input, output,session) {
  
  ############################################################
  # STEP 1: Read the data 
  read_dataset <- reactive({
    input$datafile_name_coded
    input$datafile_name
    
    # First read the pre-loaded file, and if the user loads another one then replace 
    # ProjectData with the filethe user loads
    if (input$datafile_name_coded == "Financial Sector Stocks")
      ProjectData <- FinancialsData
    if (input$datafile_name_coded == "Tech Sector Stocks")
      ProjectData <- TechData
    if (input$datafile_name_coded == "All Stocks (slow...)")
      ProjectData <- MarketData
    
    ProjectData
  })
  
  user_inputs <- reactive({
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    ProjectData = read_dataset()
    
    end_date = max(4, min(input$end_date, nrow(ProjectData)))
    start_date = min( max(1, input$start_date), end_date - 3) 
    ProjectData = ProjectData[start_date:end_date,] 
    
    list(
      ProjectData = ProjectData, 
      numb_components_used = min(max(1,input$numb_components_used),ncol(ProjectData)),
      use_mean_alpha = 0
    )
  }) 
  
  
  ############################################################
  # STEP 2: create a "reactive function" as well as an "output" 
  # for each of the R code chunks in the report/slides to use in the web application. 
  # These also correspond to the tabs defined in the ui.R file. 
  
  # The "reactive function" recalculates everything the tab needs whenever any of the inputs 
  # used (in the left pane of the application) for the calculations in that tab is modified by the user 
  # The "output" is then passed to the ui.r file to appear on the application page/
  
  ########## The Parameters Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  the_parameters_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    allparameters=c(head(rownames(ProjectData),1),tail(rownames(ProjectData),1),
                    nrow(ProjectData),ncol(ProjectData), numb_components_used, colnames(ProjectData))    
    allparameters<-matrix(allparameters,ncol=1)    
    rownames(allparameters)<-c("start date", "end date", "number of days", 
                               "number of stocks", "number of PCA components used",
                               paste("Stock:",1:ncol(ProjectData)))
    colnames(allparameters)<-NULL
    allparameters<-as.data.frame(allparameters)
    
    allparameters
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$parameters<-renderTable({
    the_parameters_tab()
  })
  
  ########## The Single Stocks Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  the_single_stocks_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    is_valid_stock<-length(which(colnames(ProjectData) == input$ind_stock))
    if (is_valid_stock != 0 ){
      stockx=ProjectData[,input$ind_stock,drop=F]
      rownames(stockx)<-rownames(ProjectData)
      colnames(stockx)<-colnames(ProjectData)[input$ind_stock]
    } else{
      stockx= NULL
    }
    stockx
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$stock_returns <- renderPlot({        
    data_used = the_single_stocks_tab()
    all_inputs <- user_inputs()
    
    if (is.null(data_used)) { 
      data_used= rep(0.01,nrow(all_inputs$ProjectData))
      plot(data_used,main=paste(paste("Stock",input$ind_stock,sep=" "), 
                                "does not exist. \nSee the Parameters tab for available stocks",sep=" "), type="l")
    } else {
      pnl_plot(data_used)              
    }
  })
  
  output$stock_pnl_matrix<-renderHeatmap({ 
    data_used = the_single_stocks_tab()
    all_inputs <- user_inputs()
    if ( is.null(data_used) ){ 
      data_used= rep(0.01,nrow(all_inputs$ProjectData))
      pnl_matrix(data_used/100) 
    } else {
      pnl_matrix(data_used/100)       
    }
    
  })
  
  
  ########## The Histogram Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  # (this is not necessary, but keeping it for consistency)
  the_histogram_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    ProjectData
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$histogram<-renderPlot({   
    data_used <- the_histogram_tab()
    hist(data_used,main="Histogram of All Daily Stock Returns",xlab="Daily Stock Returns (%)", breaks=200)
  })
  
  ########## The Market Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_market_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    market=matrix(apply(ProjectData,1,mean),ncol=1)
    rownames(market)<-rownames(ProjectData)
    market
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$market <- renderPlot({  
    data_used = the_market_tab()
    pnl_plot(data_used)    
  })
  
  output$market_pnl_matrix<-renderHeatmap({ 
    data_used = the_market_tab()
    pnl_matrix(data_used/100)
  })
  
  ########## The Market Mean-Reversion Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_market_meanreversion_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    market <- the_market_tab()
    mr_strategy = matrix(-sign(shift(market,1))*market,ncol=1)
    rownames(mr_strategy)<-rownames(market)
    mr_strategy
  })
  
  
  # Now pass to ui.R what it needs to display this tab
  output$mr_strategy <- renderPlot({        
    data_used = the_market_meanreversion_tab()
    pnl_plot(data_used)
  })
  
  output$mr_strategy_pnl_matrix<-renderHeatmap({ 
    data_used = the_market_meanreversion_tab()
    pnl_matrix(data_used/100)
  })
  
  ########## The Negative Market Mean-Reversion Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_neg_market_meanreversion_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    market <- the_market_tab()
    mr_strategy <- the_market_meanreversion_tab()
    both_markets = matrix((shift(market,1) < 0)*mr_strategy,ncol=1)
    rownames(both_markets)<-rownames(market)
    both_markets
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$both_markets <- renderPlot({        
    data_used = the_neg_market_meanreversion_tab()
    pnl_plot(data_used)
  })
  
  output$both_markets_pnl_matrix<-renderHeatmap({ 
    data_used = the_neg_market_meanreversion_tab()
    pnl_matrix(data_used/100)
  })
  
  ########## The Ordered Stocks Tab
  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_ordered_stocks_tab<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    input$order_criterion
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    use_stock = max(1, min(input$stock_order, ncol(ProjectData)))
    if (input$order_criterion == "returns")
      tmp=apply(ProjectData,2,sum)
    if (input$order_criterion == "sharpe")
      tmp=apply(ProjectData,2,sharpe)
    if (input$order_criterion == "drawdown")
      tmp=apply(ProjectData,2,function(r) -drawdown(r))
    
    chosen_id=sort(tmp,decreasing=TRUE,index.return=TRUE)$ix[use_stock]
    chosen_stock=ProjectData[,chosen_id,drop=F]
    rownames(chosen_stock)<-rownames(ProjectData)
    chosen_stock
  })
  
  # Now pass to ui.R what it needs to display this tab
  output$chosen_stock <- renderPlot({  
    chosen_stock=the_ordered_stocks_tab()
    pnl_plot(chosen_stock)
  })
  
  output$chosen_stock_pnl_matrix <- renderHeatmap({    
    chosen_stock=the_ordered_stocks_tab()
    pnl_matrix(chosen_stock/100)
  })
  
  ##############################################################################
  ##############################################################################
  
  # Now there are some shared heavy computations, so we do all of them once and pass 
  # them to all the tabs that need them. Note that this code is "cut-and-paste" from 
  # the corresponding R chunks in the report and slides .Rmd files. 
  
  heavy_computation<-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    # Keep track of all the necesssary (for the rest of the tabs) results of these calculations in 
    # a list called complex_results
    complex_results = list()
    
    SP500PCA<-PCA(ProjectData, graph=FALSE)
    complex_results$SP500PCA <- SP500PCA
    
    SP500PCA_simple<-eigen(cor(ProjectData))
    ####
    complex_results$SP500PCA_simple <- SP500PCA_simple
    Variance_Explained_Table<-SP500PCA$eig
    SP500_Eigenvalues=Variance_Explained_Table[,1]
    ####
    complex_results$SP500_Eigenvalues <- SP500_Eigenvalues
    
    PCA_first_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,1])
    if(sum(PCA_first_component)<0) PCA_first_component=-PCA_first_component                                    
    names(PCA_first_component)<-rownames(ProjectData)
    ####
    complex_results$PCA_first_component <- PCA_first_component
    PCA_second_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,2])
    if(sum(PCA_second_component)<0) PCA_second_component=-PCA_second_component
    names(PCA_second_component)<-rownames(ProjectData)
    ####
    complex_results$PCA_second_component <- PCA_second_component
    
    TheFactors=SP500PCA_simple$vectors[,1:input$numb_components_used,drop=F]
    TheFactors=apply(TheFactors,2,norm1)
    TheFactors=apply(TheFactors,2,function(r)if (sum(ProjectData%*%r)<0) -r else r)
    Factor_series=ProjectData%*%TheFactors
    demean_IVs=apply(Factor_series,2,function(r)r-use_mean_alpha*mean(r))
    ProjectData_demean=apply(ProjectData,2,function(r) r-use_mean_alpha*mean(r))
    stock_betas=(solve(t(demean_IVs)%*%demean_IVs)%*%t(demean_IVs))%*%(ProjectData_demean)
    stock_alphas= use_mean_alpha*matrix(apply(ProjectData_demean,2,mean)-t(stock_betas)%*%matrix(apply(Factor_series,2,mean),ncol=1),nrow=1)
    stock_alphas_matrix=rep(1,nrow(ProjectData))%*%stock_alphas
    # make sure each residuals portfolio invests a total of 1 dollar.
    stock_betas_stock=apply(rbind(stock_betas,rep(1,ncol(stock_betas))),2,norm1)
    stock_betas=head(stock_betas_stock,-1) # last one is the stock weight
    stock_weight=rep(1,nrow(ProjectData))%*%tail(stock_betas_stock,1)
    Stock_Residuals=stock_weight*ProjectData-(Factor_series%*%stock_betas + stock_alphas_matrix)
    colnames(Stock_Residuals)<-colnames(ProjectData)
    ###
    complex_results$Stock_Residuals <- Stock_Residuals
    
    mr_Stock_Residuals=-sign(shift(Stock_Residuals,1))*Stock_Residuals
    selected_strat_res=apply(mr_Stock_Residuals,2,function(r) if (sum(r) <= 0) -r else r)
    ###
    complex_results$mr_Stock_Residuals <- mr_Stock_Residuals
    
    res_market=apply(Stock_Residuals,1,mean)
    names(res_market)<-rownames(ProjectData)
    ###
    complex_results$res_market <- res_market
    
    selected_mr_market_res=matrix(apply(selected_strat_res,1,mean),ncol=1)
    colnames(selected_mr_market_res)<-"hindsight"
    rownames(selected_mr_market_res)<-rownames(ProjectData)
    ###
    complex_results$selected_mr_market_res <- selected_mr_market_res 
    
    # just pass this list of "complex results" to the rest of the tabs
    complex_results
    
  })
  #################################
  # Back to the rest of the tabs....  Notice that we don't always need a reactive function now, 
  # since we computed most things above.
  
  output$eigen_plot <- renderPlot({  
    complex_data <- heavy_computation()
    plot(complex_data$SP500_Eigenvalues,main="The S&P 500 Daily Returns Eigenvalues", ylab="Value")
  })
  
  output$eigen_returns <- renderPlot({   
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    complex_data <- heavy_computation()
    SP500PCA_simple<-complex_data$SP500PCA_simple
    market <- the_market_tab()
    ######
    
    # Note the abuse of the variable name: it does not need to be the first eigenvector, but we reuse code from above
    PCA_first_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,input$vector_plotted])
    if(sum(PCA_first_component)<0) PCA_first_component=-PCA_first_component                                    
    names(PCA_first_component)<-rownames(market)    
    pnl_plot(PCA_first_component)
  })
  
  output$eigen_strategy_pnl_matrix<-renderHeatmap({ 
    ###### Just load all necessary variables so that we can use the code as is from the report
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    complex_data <- heavy_computation()
    SP500PCA_simple<-complex_data$SP500PCA_simple
    market <- the_market_tab()
    ######
    
    # Note the abuse of the variable name: it does not need to be the first eigenvector
    component = max(1, min(input$vector_plotted, ncol(ProjectData)))
    PCA_first_component=ProjectData%*%norm1(SP500PCA_simple$vectors[,component])
    if(sum(PCA_first_component)<0) PCA_first_component=-PCA_first_component
    names(PCA_first_component)<-rownames(market)
    pnl_matrix(PCA_first_component/100)
  })
  
  output$chosen_residual <- renderPlot({    
    complex_data <- heavy_computation()
    Stock_Residuals <- complex_data$Stock_Residuals
    market <- the_market_tab()
    
    use_stock = max(1, min(input$residuals_order, ncol(Stock_Residuals)))
    tmp=apply(Stock_Residuals,2,sum)
    chosen_id=sort(tmp,decreasing=TRUE,index.return=TRUE)$ix[use_stock]
    chosen_stock=Stock_Residuals[,chosen_id,drop=F]
    rownames(chosen_stock)<-rownames(market)
    pnl_plot(chosen_stock)
  })
  
  output$res_market <- renderPlot({    
    complex_data <- heavy_computation()
    pnl_plot(complex_data$res_market)  
  })
  
  output$res_hindsight <- renderPlot({    
    complex_data <- heavy_computation()
    pnl_plot(complex_data$selected_mr_market_res)
  })
  
  
  # The new report 
  
  # Now the report and slides  
  # first the reactive function doing all calculations when the related inputs were modified by the user
  
  the_slides_and_report <-reactive({
    # list the user inputs the tab depends on (easier to read the code)
    input$datafile_name_coded
    input$datafile_name
    input$start_date
    input$end_date
    input$numb_components_used
    
    
    all_inputs <- user_inputs()
    ProjectData <-  all_inputs$ProjectData
    numb_components_used <- all_inputs$numb_components_used
    use_mean_alpha <- all_inputs$use_mean_alpha
    
    #############################################################
    # A list of all the (SAME) parameters that the report takes from RunStudy.R
    list(ProjectData = ProjectData, 
         start_date = 1,
         end_date = nrow(ProjectData), 
         numb_components_used = numb_components_used,
         use_mean_alpha = use_mean_alpha
    )
  })
  
  output$report = downloadHandler(
    filename <- function() {paste(paste('SP500_Report',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste('SP500_Report', 'Rmd', sep=".")
      filename.md <- paste('SP500_Report', 'md', sep=".")
      filename.html <- paste('SP500_Report', 'html', sep=".")
      
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      reporting_data<- the_slides_and_report()
      ProjectData<-reporting_data$ProjectData
      numb_components_used <- reporting_data$numb_components_used
      use_mean_alpha <- reporting_data$use_mean_alpha
      PCA_first_component<- reporting_data$PCA_first_component
      PCA_second_component<- reporting_data$PCA_second_component
      market<-reporting_data$market
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(".cache", recursive=TRUE)      
      unlink("assets", recursive=TRUE)      
      unlink("figures", recursive=TRUE)      
      
      file.copy(paste(local_directory,"doc/SP500_Report.Rmd",sep="/"),filename.Rmd,overwrite=T)
      out = knit2html(filename.Rmd,quiet=TRUE)
      
      unlink(".cache", recursive=TRUE)      
      unlink("assets", recursive=TRUE)      
      unlink("figures", recursive=TRUE)      
      file.remove(filename.Rmd)
      file.remove(filename.md)
      
      file.rename(out, file) # move pdf to file for downloading
    },    
    contentType = 'application/pdf'
  )
  
  # The new slide 
  
  output$slide = downloadHandler(
    filename <- function() {paste(paste('SP500_Slides',Sys.time() ),'.html')},
    
    content = function(file) {
      
      filename.Rmd <- paste('SP500_Slides', 'Rmd', sep=".")
      filename.md <- paste('SP500_Slides', 'md', sep=".")
      filename.html <- paste('SP500_Slides', 'html', sep=".")
      
      #############################################################
      # All the (SAME) parameters that the report takes from RunStudy.R
      reporting_data<- the_slides_and_report()
      ProjectData<-reporting_data$ProjectData
      numb_components_used <- reporting_data$numb_components_used
      use_mean_alpha <- reporting_data$use_mean_alpha
      PCA_first_component<- reporting_data$PCA_first_component
      PCA_second_component<- reporting_data$PCA_second_component
      market<-reporting_data$market
      #############################################################
      
      if (file.exists(filename.html))
        file.remove(filename.html)
      unlink(".cache", recursive=TRUE)     
      unlink("assets", recursive=TRUE)    
      unlink("figures", recursive=TRUE)      
      
      file.copy(paste(local_directory,"doc/SP500_Slides.Rmd",sep="/"),filename.Rmd,overwrite=T)
      slidify(filename.Rmd)
      
      unlink(".cache", recursive=TRUE)     
      unlink("assets", recursive=TRUE)    
      unlink("figures", recursive=TRUE)      
      file.remove(filename.Rmd)
      file.remove(filename.md)
      file.rename(filename.html, file) # move pdf to file for downloading      
    },    
    contentType = 'application/pdf'
  )
  
})
