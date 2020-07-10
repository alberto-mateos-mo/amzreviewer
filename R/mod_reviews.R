#' reviews UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_reviews_ui <- function(id){
  ns <- NS(id)
  tagList(
    shinymaterial::material_row(
      shinymaterial::material_column(
        width = 3,
        shinymaterial::material_card(
          title = "",
          tags$p("Select Locale"),
          shinymaterial::material_dropdown(input_id = ns("locale"), "", choices = c("Amazon MX" = "mx", "Amazon US" = "us"))
        ),
        shinymaterial::material_card(
          title = "",
          tags$p("Paste Amazon Product Link"),
          shinymaterial::material_text_box(input_id = ns("code"), "", icon = "link"),
          tags$p("Enter number of pages to scrape"),
          shinymaterial::material_number_box(input_id = ns("pages"), "", min_value = 1, max_value = 10, initial_value = 5),
          actionButton(ns("go"), "Analyse!")
        )
      ),
      shinymaterial::material_column(
        width = 9,
        shinymaterial::material_card(
          shinyglide::glide(
            shinyglide::screen(plotOutput(ns("adjs"))),
            shinyglide::screen(plotOutput(ns("keyw")))
          )
        )
      )
    )
  )
}
    
#' reviews Server Function
#'
#' @noRd 
mod_reviews_server <- function(input, output, session){
  ns <- session$ns
  
  x <- eventReactive(input$go, {
    code <- get_product_code(input$code)
    opiniones <- get_reviews(code, input$pages, input$locale)
    x <- udpipe_process(opiniones, input$locale)
    return(x)
  })
  
  output$adjs <- renderPlot({
    shinymaterial::material_spinner_show(session, "adjs")
    adj_stats <- x() %>%
      dplyr::filter(upos == "ADJ")
    
    adj_stats <- udpipe::txt_freq(adj_stats$lemma)
    shinymaterial::material_spinner_hide(session, "adjs")
    
    ggplot2::ggplot(head(adj_stats, 20), ggplot2::aes(reorder(key, freq_pct), freq_pct))+
      ggplot2::geom_point(colour = "#223150")+
      ggplot2::geom_linerange(ggplot2::aes(ymin = 0, ymax = freq_pct), colour = "#223150")+
      ggplot2::labs(x = "", y = "Frequency of ocurrence (%)")+
      ggplot2::ggtitle("Adjectives Most Mentioned in Reviews")+
      ggplot2::coord_flip()+
      ggplot2::theme_minimal()
  })
  
  output$keyw <- renderPlot({
    rake_stats <- udpipe::keywords_rake(x(), term = "lemma", group = "doc_id", relevant = x()$upos %in% c("NOUN", "ADJ"))
    
    ggplot2::ggplot(head(rake_stats, 20), ggplot2::aes(reorder(keyword, rake), rake))+
      ggplot2::geom_point(colour = "#223150")+
      ggplot2::geom_linerange(ggplot2::aes(ymin = 0, ymax = rake), colour = "#223150")+
      ggplot2::labs(x = "", y = "RAKE Score")+
      ggplot2::ggtitle("Keywords Found in Reviews")+
      ggplot2::coord_flip()+
      ggplot2::theme_minimal()
  })
  
}
    
## To be copied in the UI
# mod_reviews_ui("reviews_ui_1")
    
## To be copied in the server
# callModule(mod_reviews_server, "reviews_ui_1")
 
