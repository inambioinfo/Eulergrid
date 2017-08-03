
shinyUI( 
  navbarPage( "Euler Grid for Invision patients",
              

              windowTitle = "Plot", 
              inverse = TRUE, 
              tabPanel( 
                "Plot", 
                fluidPage( 
                  fluidRow( 
                    column( 
                      4, 
                      wellPanel( 
                        fileInput('datafile', 'Choose CSV file',
                                  accept=c('text/csv', 'text/comma-separated-values,text/plain')),
                        
                        #The action button prevents an action firing before we're ready
                        # actionButton("make_plot", "Get Venn Diagram"),
                        downloadButton("download_plot", "Export plot"),
                        radioButtons( "savetype", NULL, list( "png","pdf"), inline = TRUE ) 
                        
                      ), 
                      textInput("title", "Title", width = "100%"), 
                      
                      tableOutput("filetable") 
                    ), 
                    column( 
                      12, 
                      plotOutput("distPlot", height = "700px")
                      
                    ) 
                    
                    
                    
                    
                  ) 
                ) 
              ), 
              tabPanel( 
                "Information", 
                fluidPage( 
                  fluidRow( 
                    column( 
                      7, 
                      offset = 3, 
                      wellPanel( 
                        h3("Euler Grid for more than four variables"), 
                        p("This", a(href = "https://shiny.rstudio.com/", "shiny"), 
                          "app makes Euler Grid for easy visualization of overlap among differnt sets."), 
                          
                        p(" After running query in SQL Server you have to save the file in csv format. Then select the csv file from the file selector within this app. To get the
                          correct labeling of the Euler Grid use the the example query format given below"),
                        p(strong("Example Qurey")),
                        p("SELECT ACT.FYActivity, ACT.EDActivity, ACT.InpatientActivity, ACT.OutpatientActivity, COUNT(DISTINCT ActiveMRN) AS N_Pts 
                          FROM (
                          SELECT DISTINCT ENC.FYActivity, ENC.ActiveMRN, ISNULL(ADM.InpatientActivity,'N') AS InpatientActivity, 
                          ISNULL(ED.EDActivity, 'N') AS EDActivity, ISNULL(OPT.OutpatientActivity, 'N') AS OutpatientActivity
                          FROM [Invision].[sfhn].[tblEncounter] ENC
                          LEFT JOIN (
                          SELECT ActiveMRN, 'Y' AS InpatientActivity
                          FROM [Invision].[sfhn].[tblEncounter]
                          WHERE FYActivity = 'FY1516' AND SourceTable = 'Invision.dbo.tblAdmit'
                          ) ADM ON ADM.ActiveMRN = ENC.ActiveMRN
                          LEFT JOIN (
                          SELECT ActiveMRN, 'Y' AS EDActivity
                          FROM [Invision].[sfhn].[tblEncounter]
                          WHERE FYActivity = 'FY1516' AND SourceTable = 'Invision.dbo.tblED'
                          ) ED ON ED.ActiveMRN = ENC.ActiveMRN
                          LEFT JOIN (
                          SELECT ActiveMRN, 'Y' AS OutpatientActivity   
                          FROM [Invision].[sfhn].[tblEncounter]
                          WHERE FYActivity = 'FY1516' AND SourceTable = 'Invision.dbo.tblOutpatient'
                          ) OPT ON OPT.ActiveMRN = ENC.ActiveMRN
                          WHERE ENC.FYActivity = 'FY1516'
                          ) ACT
                          GROUP BY ACT.FYActivity, ACT.EDActivity, ACT.InpatientActivity, ACT.OutpatientActivity"), 
                        
                        
                        br(), 
                        p("A K M Tanzir Hasan"), 
                        p (a( href="mailto:hitanzir@gmail.com","hitanzir@gmail.com" ))
                        ) 
                        )
 
                ) 
                ) 
                ) 
              ) 
  )
