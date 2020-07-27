#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinymaterial
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    # golem_add_external_resources(),
    # List the first level UI elements here 
    shinymaterial::material_page(
      primary_theme_color = "#3a5250",
      secondary_theme_color = "#3a5250",
      background_color = "black",
      font_color = "white",
      title = "Amazon Reviews Analyser",
      tags$br(),
      mod_reviews_ui("reviews_ui_1")
    )
  )
}

#' #' Add external Resources to the Application
#' #' 
#' #' This function is internally used to add external 
#' #' resources inside the Shiny application. 
#' #' 
#' #' @import shiny
#' #' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' #' @noRd
#' golem_add_external_resources <- function(){
#'   
#'   add_resource_path(
#'     'www', app_sys('app/www')
#'   )
#'  
#'   tags$head(
#'     favicon(),
#'     bundle_resources(
#'       path = app_sys('app/www'),
#'       app_title = 'amzreviewer'
#'     )
#'     # Add here other external resources
#'     # for example, you can add shinyalert::useShinyalert() 
#'   )
#' }

