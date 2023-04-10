setClass(Class = "RawMsParameterClass",
         representation(name = "character",
                        para_peak_detection = "list",
                        para_rt_correction = "list",
                        para_peak_grouping = "list")
)


#' @title initialize_raw_parameter_class
#' @description generate a RawMsParameterClass for processing raw mass spec data
#' @author Zhiwei Zhou
#' @param column 'hilic', 'c18'
#' @return
#'  a object of RawMsParameterClass, with slots:
#'  \describe{
#'  \item{name}-{parameter set name}
#'  \item{para_peak_detection}-{parameter of peak detection}
#'  \item{para_peak_detection - method}-{peak detection method. Default: "centWave".}
#'  \item{para_peak_detection - method}-{peak detection method. Default: "centWave".}
#'  }
#' @importFrom magrittr %>%
#' @importFrom crayon blue red yellow green bgRed
#' @importFrom stringr str_detect str_extract
#' @export
#' @examples
#' object <- initialize_raw_parameter_class(column = 'hilic')

# object <- initialize_raw_parameter_class(column = 'hilic')

setGeneric(name = 'initialize_raw_parameter_class',
           def = function(
    column = c('hilic', 'c18')
           ){
             column <- match.arg(column)
             message(crayon::blue('Initialize raw ms parameter class...\n'))

             if (column == 'hilic') {
               para_peak_detection <- list(method = 'centWave',
                                          ppm = 20,
                                          snthr = 10,
                                          peakwidth = c(10, 44),
                                          mzdiff = -0.001,
                                          nSlaves = 6)

               para_rt_correction <- list(method = 'obiwarp',
                                         plottype = 'deviation',
                                         profStep = 0.1)

               para_peak_grouping <- list(method="density",
                                          bw = 5,
                                          mzwid = 0.015,
                                          minfrac = 0.5)
             }

             if (column == 'c18') {
               para_peak_detection <- list(method = 'centWave',
                                           ppm = 20,
                                           snthr = 10,
                                           peakwidth = c(10, 78),
                                           mzdiff = -0.02,
                                           nSlaves = 6)

               para_rt_correction <- list(method = 'obiwarp',
                                          plottype = 'deviation',
                                          profStep = 0.1)

               para_peak_grouping <- list(method="density",
                                          bw = 5,
                                          mzwid = 0.015,
                                          minfrac = 0.5)
             }


             para_list <- new(Class = 'RawMsParameterClass',
                              name = column,
                              para_peak_detection = para_peak_detection,
                              para_rt_correction = para_rt_correction,
                              para_peak_grouping = para_peak_grouping)

             return(para_list)
           }
)




setMethod(f = "show",
          signature = "RawMsParameterClass",
          definition = function(object) {
            cat("------------------------------\n")
            message(crayon::blue("Parameter set:", object@name))
            # cat("Parameter set name:", object@name, "\n")
            cat("------------------------------\n")
            message(crayon::blue("Peak detection:"))
            # cat("Peak detection:\n")
            cat("method:", object@para_peak_detection$method, "\n")
            cat("ppm:", object@para_peak_detection$ppm, "\n")
            cat("peakwidth:", object@para_peak_detection$peakwidth, "\n")
            cat("mzdiff:", object@para_peak_detection$mzdiff, "\n")
            cat("nSlaves:", object@para_peak_detection$nSlaves, "\n")
            cat("------------------------------\n")
            message(crayon::blue("Peak RT correction:"))
            # cat("Peak RT correction:\n")
            cat("method:", object@para_rt_correction$method, "\n")
            cat("plottype:", object@para_rt_correction$plottype, "\n")
            cat("profStep:", object@para_rt_correction$profStep, "\n")
            cat("------------------------------\n")
            message(crayon::blue("Peak grouping:"))
            # cat("Peak grouping:\n")
            cat("method:", object@para_peak_grouping$method, "\n")
            cat("bw:", object@para_peak_grouping$bw, "\n")
            cat("mzwid:", object@para_peak_grouping$mzwid, "\n")
            cat("minfrac:", object@para_peak_grouping$minfrac, "\n\n")
          }
)
