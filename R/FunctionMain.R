#' @title process_raw_data
#' @author Zhiwei Zhou
#' @description a R wrapper to run xcms for raw MS data processing
#' @param parameter_set a parameter set class object (RawMsParameterClass). It can be generated easily by running \code{initialize_raw_parameter_class()}
#' @param path the path of raw MS data files
#' @importFrom magrittr %>%
#' @importFrom crayon blue red yellow green bgRed
#' @importFrom stringr str_detect str_extract
#' @export
#' @examples
#' parameter_set <- initialize_raw_parameter_class(column = 'hilic')
#' process_raw_data(parameter_set = parameter_set, path = '~/Project/00_IBD_project/Data/20230327_raw_data_processing_test/DemoData/')


# parameter_set <- initialize_raw_parameter_class(column = 'hilic')
# process_raw_data(parameter_set = parameter_set, path = '~/Project/00_IBD_project/Data/20230327_raw_data_processing_test/DemoData/')

setGeneric(name = 'process_raw_data',
           def = function(parameter_set = NULL,
                          path = '.'){

             if (is.null(parameter_set)) {
               stop('Please provide parameter_set for raw MS data processing')
             }

             if (class(parameter_set) != "RawMsParameterClass") {
               stop("The parameter_set is not a RawMsParameterClass object")
             }
             path_output <- file.path(path, '00_raw_data_processing')

             message(crayon::blue('01: Peak detection...'))
             # peak detection
             # Note: nSlave is the processor number for data processing. It can be changed according to the server and resource
             f.in <- list.files(pattern = '\\.(mz[X]{0,1}ML|cdf)', path = path, recursive = TRUE)
             f.in <- f.in[dirname(f.in)!='ms2']

             if (length(path_output) == 0) {
               stop('There no raw MS data files found!')
             }

             xset <- xcms::xcmsSet(file.path(path, f.in),
                                   method = parameter_set@para_peak_detection$method,
                                   ppm = parameter_set@para_peak_detection$ppm,
                                   snthr = parameter_set@para_peak_detection$snthr,
                                   peakwidth = parameter_set@para_peak_detection$snthr,
                                   mzdiff = parameter_set@para_peak_detection$mzdiff,
                                   nSlaves = parameter_set@para_peak_detection$nSlaves)

             dir.create(file.path(path_output, '00_intermediate_data'), showWarnings = FALSE, recursive = TRUE)
             save(xset, file = file.path(path_output, '00_intermediate_data', 'xset1.RData'))


             message(crayon::blue('02: RT correction...'))
             # retention time correction
             pdf(file.path(path_output, 'rt_correction_obiwarp.pdf'))
             xsetc <-  xcms::retcor(xset,
                                    method = parameter_set@para_rt_correction$method,
                                    plottype = parameter_set@para_rt_correction$plottype,
                                    profStep = parameter_set@para_rt_correction$profStep)
             dev.off()
             save(xsetc, file = file.path(path_output, '00_intermediate_data', 'xset1_c.RData'))

             # peak grouping
             message(crayon::blue('03: peak groupping...'))
             xset2 <- xcms::group(xsetc,
                                  bw = parameter_set@para_peak_grouping$bw,
                                  mzwid = parameter_set@para_peak_grouping$mzwid,
                                  minfrac = parameter_set@para_peak_grouping$minfrac)
             save(xset2, file = file.path(path_output, '00_intermediate_data', 'xset2.RData'))


             # gap filling
             message(crayon::blue('04: gap filling...'))
             xset3 <- xcms::fillPeaks(xset2)
             save(xset3, file = file.path(path_output, '00_intermediate_data', 'xset3.RData'))

             # peak table outputting
             values <- xcms::groupval(xset3, "medret", value = "into")
             values.maxo <- xcms::groupval(xset3, "medret", value = 'maxo')
             values.maxint <- apply(values.maxo, 1, max)
             peak.table <- cbind(name = xcms::groupnames(xset3),
                                 groupmat = xcms::groups(xset3),
                                 maxint = values.maxint,
                                 values)

             rownames(peak.table) <- NULL
             write.csv(peak.table, file.path(path_output, "Peak-table.csv"), row.names = FALSE)

             message(crayon::blue('Raw MS data processing: Done!\n'))
           })
