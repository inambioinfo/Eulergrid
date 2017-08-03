library(shiny)
shinyServer(function(input, output) { 
  
  #This function is repsonsible for loading in the selected file 
  filedata <- reactive({ 
    infile <- input$datafile 
    if (is.null(infile)) { 
      # User has not uploaded a file yet 
      return(NULL) 
    } 
    read.csv(infile$datapath, stringsAsFactors = FALSE) 
  }) 
  
  
  
  #This previews the CSV data file 
  output$filetable <- renderTable({ 
    filedata() 
  }) 
  
  
  
  
  output$distPlot <- renderPlot({
    # generate bins based on input$bins from ui.R
    df=filedata() 
    make_plot()
    
    
    
  })
  
  #This function is the one that is triggered when the action button is pressed 
  #The function is a geocoder from the ggmap package that uses Google maps geocoder to geocode selected locations 
  make_plot <- function(){ 
    #if (input$datafile == 0) return(NULL) 
    df=filedata() 
    
    
    if (is.null(df)) return(NULL) 
    if( ncol(df)== 7 ) {  
      
      df[df== "N"] <-0
      df[df== "Y"] <-1
      
      prettyTicks.old <- function(valueRange, n.ticks=3, inc.zero = FALSE)  {
        max.value <- max(valueRange)
        n.signif <- min(nchar(max.value)-1, 2)
        max.tick <- signif(max.value, n.signif)
        interval <- max.tick/n.ticks
        ticks <- seq(0, max.tick, interval)
        if(!inc.zero)	ticks <- ticks[-1]
        ticks <- signif(ticks, n.signif)
        return(ticks)
      }
      
      prettyTicks <- function(valueRange, n.ticks=3, inc.zero = FALSE)  {
        max.value <- max(valueRange)
        
        # find suitable interval
        n.signif <- 1 
        interval <- signif(max.value/n.ticks, n.signif)
        while(interval*(n.ticks-1) >= max.value) {
          n.signif <- n.signif +  1
          interval <- signif(max.value/n.ticks, n.signif)
        }
        ticks <- seq(0, by=interval, length.out=n.ticks)
        if(!inc.zero)	ticks <- ticks[-1]
        return(ticks)
      }
      
      
      
      
      ## prototype code using built-in functions barplot() and image()
      ## Two separate plotting areas required and two plots would not align (something weird about 'image()')
      plotEuler.old <- function(binaryGrid, counts, labels)  {
        par(mfrow=c(2,1))
        n.groups <- length(counts)
        n.samples <- ncol(binaryGrid)
        barplot(counts, space=0, beside=T)
        image(as.matrix(binaryGrid), col=c("grey","darkolivegreen4"), axes = F)
        axis(side=2, at=seq(0,1,length.out=n.samples),labels=labels, las=2)
        grid(nx=nrow(binaryGrid),ny=n.samples, col="grey20", lwd=2)
        box( col="grey20", lwd=2)
        
      }
      
      
      ### main plotting function for EulerGrid
      # binaryGrid	a data.frame containing only 0/1. One column per sample. 
      # counts		vector of counts. Must match number of rows in binary grid (and in same order)
      # labels
      plotEuler <- function(binaryGrid, counts, labels=colnames(binaryGrid), y_buffer=0.1, bar.prop=0.5, dropEmptySet=TRUE, dropFullSet=FALSE, dropSets='', fg.colour="darkolivegreen4",bg.colour="grey")  {
        
        n.samples <- ncol(binaryGrid)
        
        #rownames(binaryGrid) <- apply(binaryGrid)     # should already be binary chain matching the row if user used scoreCardinalities()
        
        # allow removal of certain sets from the table of counts (e.g. empty set , full set)
        if(dropEmptySet)  {
          dropSets <- intersect(rownames( binaryGrid),unique(c(dropSets, paste(rep(0,n.samples),collapse=""))))
        }
        if(dropFullSet)  {
          dropSets <- intersect(rownames( binaryGrid),unique(c(dropSets, paste(rep(1,n.samples),collapse=""))))
        }
        print(paste("Dropping:", paste(dropSets, collapse=",")))
        
        keepSet <- setdiff(rownames(binaryGrid), dropSets)
        keepSetIndex <- match(keepSet , rownames(binaryGrid))
        
        # remove unwanted sets.
        binaryGrid <- binaryGrid[keepSetIndex,]
        counts <- counts[keepSetIndex]
        n.counts <- length(counts)
        
        grid.height <- 2 - (bar.prop * 2)
        bar.bottom <- grid.height + y_buffer
        max.count <- max(counts)
        
        # all rects in grid, specified by rows from bottom, moving left to right
        grid.x1 <- rep(seq(0,1,length.out=n.counts+1)[-(n.counts + 1)] , n.samples)
        grid.x2 <- rep(seq(0,1,length.out=n.counts+1)[-1] , n.samples)
        grid.y1 <- rep(seq(0,grid.height,length.out=n.samples+1)[-(n.samples + 1)] , each=n.counts)
        grid.y2 <- rep(seq(0,grid.height,length.out=n.samples+1)[-1] ,each= n.counts)
        
        colVector <- unlist(binaryGrid)   # concatenation by colums - to be used as rows from bottom, left to right.
        colVector <- ifelse(colVector == 1,fg.colour, bg.colour )
        
        # begin plotting
        plot.new()
        par(mai = c(2,3,2,0.5) + 0.1)
        plot.window(xlim=c(0,1),ylim=c(0,1+bar.bottom))
        title(main = input$title)
        # draw the grid and add labels
        rect(grid.x1, grid.y1, grid.x2, grid.y2 , col=colVector)
        labelPosVector <- (seq(0,grid.height,length.out=n.samples+1)[-(n.samples + 1)])  + (seq(0,1,length.out=n.samples+1)[2] /2)
        mtext(labels, side=2, at=labelPosVector, las=2)
        
        # draw the bargraph and add an axis
        rect(seq(0,1,length.out=n.counts+1)[-(n.counts+1)],  bar.bottom , seq(0,1,length.out=n.counts+1)[-1], (counts/max.count) + bar.bottom , col="grey")
        #tickVector <- prettyTicks(range(counts), n.ticks=4,inc.zero=T)
        tickVector <- pretty(0:max(counts))
        tickPosVector <- (tickVector/max.count) + bar.bottom
        axis(at=tickPosVector , side=2, labels =tickVector, las=2)
        
      }
      plotEuler(df[,1:6], df$N_Pts, names(df[,1:6]))
      
    } 
    if (ncol(df)==6){
      
    }
  }
  # Download the plot 
  output$download_plot <- downloadHandler( 
    filename = function(){ 
      paste0("Euler-", Sys.Date(), ".", input$savetype) 
    }, 
    content = function(file) { 
      switch(input$savetype, 
             pdf = pdf(file), 
             png = png(file, type = "cairo", width = 648, height = 648)) 
      print( make_plot()) 
      dev.off() 
    } 
  )
})
  
