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
          shinymaterial::material_number_box(input_id = ns("pages"), "", min_value = 1, max_value = 50, initial_value = 10),
          actionButton(ns("go"), "Analyse!")
        )
      ),
      shinymaterial::material_column(
        width = 9,
        shinymaterial::material_card(
          shinyglide::glide(
            shinyglide::screen(label = "Adjectives mentioned in reviews:", plotOutput(ns("adjs"))),
            shinyglide::screen(label = "Keywords found in reviews:", plotOutput(ns("keyw")))
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
    
    ggplot2::ggplot(adj_stats, ggplot2::aes(label = key, size = freq_pct), colour = "#020200")+
      ggwordcloud::geom_text_wordcloud(shape = "square")+
      ggplot2::scale_size(range = c(1, 15))
  })
  
  output$keyw <- renderPlot({
    rake_stats <- udpipe::keywords_rake(x(), term = "lemma", group = "doc_id", relevant = x()$upos %in% c("NOUN", "ADJ"))
    
    ggplot2::ggplot(rake_stats, ggplot2::aes(label = keyword, size = rake*freq))+
      ggwordcloud::geom_text_wordcloud(shape = "square")+
      ggplot2::scale_size(range = c(1, 15))
  })
  
}
    
## To be copied in the UI
# mod_reviews_ui("reviews_ui_1")
    
## To be copied in the server
# callModule(mod_reviews_server, "reviews_ui_1")
 
