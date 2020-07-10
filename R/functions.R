#' Cleans reviews
#' 
#' @param reviews Character vector
#' @noRd

clean_reviews <- function(reviews){
  
  cleaned <- stringr::str_replace_all(reviews, "[\r\n]", "") %>% 
    stringr::str_replace_all(., "[.]", " ") %>% 
    stringr::str_replace_all(., "[,]", " ") %>% 
    stringr::str_replace_all(., "[;]", " ") %>% 
    stringr::str_replace_all(., "[\"]", " ") %>% 
    tolower() %>% 
    trimws() %>% 
    paste(collapse = " ")
  
  return(cleaned)
  
}

#' Scrapes reviews
#' 
#' @param id Character, amazon product ID
#' @param pages Number of pages to scrape content
#' @param locale Locale of the amazon site, either "mx" or "us"
#' @noRd

get_reviews <- function(id, pages, locale){
  
  if(locale == "mx"){
    webpage <- paste0("https://www.amazon.com.mx/product-reviews/", id) 
  }else if(locale == "us"){
    webpage <- paste0("https://www.amazon.com/product-reviews/", id)
  }else{
    stop("Locale not available")
  }
  
  session <- polite::bow(webpage)
  
  reviews_list <- purrr::map(1:pages, ~polite::scrape(session, query = list(pageNumber = .x)) %>% 
                        rvest::html_nodes("[class='a-size-base review-text review-text-content']") %>% 
                        rvest::html_text())
  
  reviews <- clean_reviews(unlist(reviews_list))
  
  return(reviews)
  
}

#' Annotates reviews with udpipe models
#' 
#' @param reviews Character vector
#' @param locale Locale of the amazon site, either "mx" or "us"
#' @noRd

udpipe_process <- function(reviews, locale){
  if(locale == "mx"){
    x <- udpipe::udpipe_annotate(model_sp, reviews)
    x <- as.data.frame(x, detailed = TRUE)
    return(x)
  }else if(locale == "us"){
    x <- udpipe::udpipe_annotate(model_en, reviews)
    x <- as.data.frame(x, detailed = TRUE)
    return(x)
  }
}

#' Gets amazon product code given url
#' 
#' @param url URL of the amazon product
#' @noRd

get_product_code <- function(url){
  chunked_url <- unlist(strsplit(url, "/"))
  pos <- which(chunked_url == "dp")
  code <- chunked_url[pos+1]
  return(code)
}