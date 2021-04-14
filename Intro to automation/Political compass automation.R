  library(tidyverse)
  library(tidytext)


  compass <- ggplot(gafl, mapping = aes(x = Economic, y = Social)) +
          annotate("rect", xmin = 300, xmax = 0, 
                   ymin = 100, ymax = 0, fill= "#40acff", alpha = 0.5)  + 
          annotate("rect", xmin = -100, xmax = 0, 
                   ymin = -100, ymax = 0 , fill= "#f97c7c", alpha = 0.5) + 
          annotate("rect", xmin = 0, xmax = 100, 
                   ymin = 0, ymax = -100, fill= "#fdfd96", alpha = 0.5) + 
          annotate("rect", xmin = 0, xmax = -100, 
                   ymin = 100, ymax = 0, fill= "#a0e7a0", alpha = 0.5) + 
          annotate("segment", x = 0, xend = 0, y = -100, yend = 100, color = 'black') +
          annotate("segment", x = -100, xend = 100, y = 0, yend = 0, color = 'black')+
          geom_point() + theme_bw() + 
          theme(panel.grid = element_line(colour = "gray", size = 0.5)) + 
          xlab('Libertarian') + ylab('Progressive')+
          scale_y_continuous(expand = c(0, 0), breaks = seq(-100,100,10), 
                             sec.axis = dup_axis(name = 'Conservative')) + 
          scale_x_continuous(expand = c(0, 0), breaks = seq(-100,100,10), 
                             sec.axis = dup_axis(name = 'Authoritation')) 
  
  compass
