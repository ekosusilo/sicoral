# ==================================================== # 
# SHINY UI ---- 
# ==================================================== # 

ui <- navbarPage("Coral Bleaching Early Warning System",
                 windowTitle = "SICORAL",
                 
                 # PLOTTING PANEL ----
                 tabPanel("Time Series Plot",
                   sidebarLayout(
                     sidebarPanel(
                       
                       span(tags$i(h6("Coral Bleaching Early Warning System for CTI Regions")), style = "color:#045a8d"),
                       
                       ## select input region ----
                       pickerInput(
                         "region_select", "PILIH AREA :",
                         choices = roi$fullname,
                         selected = roi$fullname[1],
                         multiple = FALSE),
                       
                       ## select date range ----
                       sliderInput(
                         "minimum_date", "DATE RANGE:",
                         min =  min(date_range),
                         max =  max(date_range),
                         value = c(min(week_range), max(week_range)),
                         # value = min(week_range),
                         timeFormat = "%d %b %Y",
                         dragRange = TRUE),
                       
                       span(tags$b(h6("2022 | Balai Pengelolaan Informasi Sumberdaya Kelautan dan Perianan")), style = "color:#045a8d")
                     ),
                     
                     mainPanel(
                       # plot graph
                       downloadButton("download_png","DOWNLOAD GRAPH"),
                       plotOutput("plot_bba", width = "100%"),
                       
                       br(),br(),br(),br(),br(),br(),br(),br(),br(),
                       
                       # dataset table
                       downloadButton("download_csv","DOWNLOAD CSV"),
                       dataTableOutput("table_ts"),
                       
                       # roi table
                       #dataTableOutput("table_roi"),
                       
                     )
                   )
                 ),
                 
                 # MAPPING PANEL ----
                 tabPanel('Heat Stress Map',
                   # generate sidebar layout ----
                   sidebarLayout(      
                     
                     # generate sidebar panel ----
                     sidebarPanel(
                       
                       span(tags$i(h6("Coral Bleaching Early Warning System for CTI Regions")), style = "color:#045a8d"),
                       
                       ## select dataset ----
                       pickerInput(
                         "dataset_select", "PILIH DATASET :",
                         choices = unique(dat$dataset_id),
                         selected = unique(dat$dataset_id)[1],
                         multiple = FALSE),
                       
                       ## select variable ----
                       pickerInput(
                         "variable_select", "PILIH VARIABEL :",
                         choices = unique(dat$variable_name),
                         selected = unique(dat$variable_name)[1],
                         multiple = FALSE),
                       
                       ## select date ----
                       # airDatepickerInput(
                       #   'date_select', label = 'PILIH TANGGAL (SABTU):',
                       #   value = Sys.Date()),
                       
                       sliderTextInput(
                         "date_select",
                         "PILIH TANGGAL:",
                         choices = format(week_range, "%d %b %y"),
                         selected = format(max(week_range), "%d %b %y"),
                         grid = FALSE,
                         animate=animationOptions(interval = 10000, loop = T)),
                       
                       
                       span(tags$b(h6("2022 | Balai Pengelolaan Informasi Sumberdaya Kelautan dan Perianan")), style = "color:#045a8d")
                     ),
                     
                     
                     # generate main panel ----
                     mainPanel(
                       leafletOutput('heat_map', height=900)
                     )
                   )    
                 ),
                 
                 # INFO PANEL ----
                 tabPanel("INFO",
                   mainPanel(
                     "Prototype sistem peringatan dini permutihan karang disusun berdasarkan trend kenaikan suhu permukaan laut dan anomali tinggi muka laut dengan studi kasus 7 ekosistem terumbu karang di wilayah segitiga karang (coral triangle). "
                   )
                 )
)