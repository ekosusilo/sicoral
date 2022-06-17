# ==================================================== # 
# SHINY SERVER ---- 
# ==================================================== # 

function(input, output) {

# PART 1 ----
  ## region of interest attribute ----
  roi_reactive = reactive({
    roi %>% filter(fullname == input$region_select)
    }
  )
  
  ## date range attribute ----
  x_limit<-reactive({
    x_limit <- length(seq.Date(input$minimum_date[1], input$minimum_date[2], by = 'month'))
    }
  )

  
  ## load dataset ----
  ts_reactive <- reactive({
    # select dataset based on area date range input
    ts_name<- paste0('ts_',roi_reactive()$id_name,'.txt')
    drop_download(paste0('sicoral/',ts_name), local_path = ts_name, overwrite = TRUE)
    ts <- read.table(ts_name, as.is = T, header = T, sep = '\t')
    ts <- ts[ts$tanggal >= input$minimum_date[1] & ts$tanggal<=input$minimum_date[2],]
    }
  )
  
  ## add bleaching color alert into dataset ----
  ts_reactive_color<-reactive({
    ts <- ts_reactive()
    
    ts$ba_bar<--1
    ts$color[ts$ba_ct5km<=0]<-'cyan'
    ts$color[ts$ba_ct5km>0 & ts$ba_ct5km<=1]<-'yellow'
    ts$color[ts$ba_ct5km>1 & ts$ba_ct5km<=2]<-'darkorange'
    ts$color[ts$ba_ct5km>2 & ts$ba_ct5km<=3]<-'red'
    ts$color[ts$ba_ct5km>3]<-'darkred'
    
    ts
    }
  )
  
  ## plot function ----
  sicoral_plot <- function(file) {
    ### setup graphical margin ----
    par(mar = c(4, 4, 4, 4) + 0.3)
    
    ### draw axis y1 (primary) ----
    #### SST-SiCORAL ----
    plot(as.Date(ts_reactive_color()$tanggal), ts_reactive_color()$sst_ct5km, xaxt = "n",
         type = "l", lty = 3, lwd = 1, col = "black",
         ylim = c(22,33),
         ylab = "SST (Â°C)", xlab = "")
    
    #### Bleaching Threshold and MMM ----
    abline(h = roi_reactive()$ct5avg+1, col = 'green', lty = 1, lwd = 1)
    abline(h = roi_reactive()$ct5avg, col = 'green', lty = 3, lwd = 1.2)
    
    #### SST-CoralWacth (ct5km) ----
    lines(as.Date(ts_reactive_color()$tanggal), ts_reactive_color()$sst_mur, col = 'magenta', lty = 1, lwd = 1.5)
    
    #### Setup title & axis ----
    mtext(input$region_select, side = 3, line = 2, cex = 1.5)
    axis(side = 2, at = pretty(c(22,32)), col = 'black')
    rug(x = seq(22,33,0.5), ticksize = -0.015, side = 2)
    
    if (x_limit() <= 6) {
      axis.Date(1, at = seq.Date(input$minimum_date[1], input$minimum_date[2], by = 'week'), format = "%d %b %Y")
    } else if (x_limit() <= 36 & x_limit() > 6) {
      axis.Date(1, at = seq.Date(input$minimum_date[1], input$minimum_date[2], by = 'month'), format = "%b-%Y")
    } else {
      axis.Date(1, at = seq.Date(input$minimum_date[1], input$minimum_date[2], by = '6 month'), format = "%b-%Y")
    }
    
    ### draw axis y2 (secondary) ----
    #### DHW-CoralWacth (ct5km) ----
    par(new = TRUE)
    barplot(ts_reactive_color()$dhw_ct5km, space = 0,
            col = ts_reactive_color()$color,
            border = ts_reactive_color()$color,
            axes = FALSE, xlab = "", ylab = "", ylim = c(-1,26))
    lines(ts_reactive_color()$dhw_ct5km, col = 'blue', lty = 3, lwd = 1)
    
    #### DHW-SiCORAL ----
    par(new = TRUE)
    lines(ts_reactive_color()$dhw_mur, col = 'blue', lty = 1, lwd = 1)
    
    #### DHW Trashold ----
    abline(h = 4, col = 'red', lty = 3)
    abline(h = 8, col = 'red', lty = 3)
    
    #### Setup axis ----
    axis(side = 4, at = pretty(c(-1,26)), col = 'red', col.axis = 'red')
    rug(x = seq(0,25,1), ticksize = -0.015, col = 'red', side = 4)
    mtext("DHW (Â°C Week)", side = 4, line = 3, col = 'red')
    
    #### draw BAA-CoralWacth (ct5km)  ----
    par(new = TRUE)
    barplot(ts_reactive_color()$ba_bar, space = 0,
            col = ts_reactive_color()$color,
            border = ts_reactive_color()$color,
            axes = FALSE, xlab = "", ylab = "", ylim = c(-1,26))
    abline(h = 0, col = 'black', lty = 1)
    
    ### draw legend ----
    box()
    legend("topleft", inset = c(0.01, 0.01), horiz = F, cex = 0.8, box.lty = 0, lwd = 1.5,
           c("SST Bleaching Threshold", "SST Max Monthly Mean"),
           col = 'green', lty = c(1,3))
    
    legend("topleft", inset = c(0.35, 0.01), horiz=F, cex = 0.8, box.lty = 0, lwd = c(2,1.5),
           c("SST_MUR","SST_ct5km"),
           col=c('magenta','black'), lty=c(1,3))
    
    legend("topleft", inset = c(0.58, 0.01), horiz = F, cex = 0.8, box.lty = 0, lwd = c(2,1.5),
           c('DHW_MUR','DHW_ct5km'),
           col = 'blue', lty = c(1,3))
    
    legend("topleft", inset = c(0.78, 0.01), horiz = F, cex = 0.8, box.lty = 0, lwd = 1.5,
           c("4 & 8 DHWs"),
           col='red', lty=3)
    
    legend('bottom', inset = c(0, 1), horiz=T, box.lty = 0, xpd = TRUE, bty = "n", cex = 0.8,
           c('No Stress','Watch', 'Warning', 'Alert Level 1', 'Alert Level 2'),
           fill = c('cyan', 'yellow', 'darkorange', 'red','darkred'))
  }
  
  ## render graph ----
  output$plot_bba <- renderPlot({
    sicoral_plot(file)
  }, width = 1000, height = 600, res = 110)
  
  ## export/download graph ----
  output$download_png <- downloadHandler(
    filename = function() {
      paste0(roi_reactive()$id_name,"_",format(input$minimum_date[1],"%Y%m%d"),"_",format(input$minimum_date[2],"%Y%m%d"),".png")},
    
    content = function(file) {
      png(file, width = 1000, height = 600, res = 110)
        sicoral_plot(file)
      dev.off()
    }
  )

  ## render table ----
  output$table_roi <- renderDataTable(datatable({roi_reactive()}))
  output$table_ts <- renderDataTable(datatable({ts_reactive()[order(ts_reactive()$tanggal),]}, rownames = F))
  
  ## export/download dataset ----
  output$download_csv <- downloadHandler(
    filename = function() {
      paste0(roi_reactive()$id_name,"_",format(input$minimum_date[1],"%Y%m%d"),"_",format(input$minimum_date[2],"%Y%m%d"),".csv")},
    
    content = function(file) {
      write.csv(ts_reactive(), file, row.names = F )
    }
  )


}