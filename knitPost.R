

knitPost <- function(site_path = "/Users/kurtpeters/Documents/R/rebelrebel04.github.io/", flag_overwrite_all = FALSE, overwrite_one = NULL) {
  
  # site.path = directory of jekyll blog (including trailing slash)
  
  #if(!'package:knitr' %in% search()) library('knitr')
  
  ## Blog-specific directories. This will depend on how you organize your blog.
  rmd_path <- paste0(site_path, "_rmd") # directory where your Rmd-files reside (relative to base)
  fig_dir <- "assets/Rfig/" # directory to save figures
  posts_path <- paste0(site_path, "_posts/articles") # directory for converted markdown files
  cache_path <- paste0(site_path, "_cache") # necessary for plots
  
  knitr::render_jekyll(highlight = "pygments")
  knitr::opts_knit$set(base.url = "/", base.dir = site_path)
  knitr::opts_chunk$set(
    fig.path = fig_dir, 
    fig.width = 8.5, 
    fig.height = 5.25, 
    dev = "svg", 
    cache = FALSE,
    warning = FALSE,
    message = FALSE, 
    cache.path = cache_path, 
    tidy = FALSE
    )   

  setwd(rmd_path) # setwd to base
  
  # some logic to help us avoid overwriting already existing md files
  files.rmd <- data.frame(
    rmd = list.files(
      path = rmd_path,
      full.names = TRUE,
      pattern = "\\.Rmd$",
      ignore.case = TRUE,
      recursive = FALSE
    ),
    stringsAsFactors = FALSE
  )
  files.rmd$corresponding.md.file <- paste0(posts_path, "/", basename(gsub(pattern = "\\.Rmd$", replacement = ".md", x = files.rmd$rmd)))
  files.rmd$corresponding.md.exists <- file.exists(files.rmd$corresponding.md.file)
  
  ## determining which posts to overwrite from parameters overwrite_one & flag_overwrite_all
  files.rmd$md.overwriteAll <- flag_overwrite_all
  if(!is.null(overwrite_one)) files.rmd$md.overwriteAll[grep(overwrite_one, files.rmd[,'rmd'], ignore.case = TRUE)] <- TRUE
  files.rmd$md.render <- FALSE
  for (i in 1:nrow(files.rmd)) {
    if (!files.rmd$corresponding.md.exists[i]) {
      files.rmd$md.render[i] <- TRUE
    }
    if ((files.rmd$corresponding.md.exists[i]) && (files.rmd$md.overwriteAll[i])) {
      files.rmd$md.render[i] <- TRUE
    }
  }
  
  # For each Rmd file, render markdown (contingent on the flags set above)
  for (i in 1:nrow(files.rmd)) {
    if (files.rmd$md.render[i]) {
      out_file <- knitr::knit(
        files.rmd$rmd[i], 
        output = files.rmd$corresponding.md.file[i],
        envir = parent.frame(),
        quiet = TRUE
      )
      message("knitPost: ", basename(files.rmd$rmd[i]))
    }     
  }
  
}