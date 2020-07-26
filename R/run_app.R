#' Run the Shiny Application
#'
#' @param options A series of options to be used inside the app.
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options

run_app <- function(options = list()) {
  shiny::shinyApp(ui = app_ui,
                  server = app_server,
                  options = options) 
}

# run_app <- function(
#   options = list()
# ) {
#   with_golem_options(
#     app = shinyApp(
#       ui = app_ui, 
#       server = app_server
#     ), 
#     golem_opts = options
#   )
# }
