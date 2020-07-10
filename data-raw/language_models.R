## code to prepare `language_models` dataset goes here

model_en <- udpipe::udpipe_load_model("data-raw/english-ewt-ud-2.4-190531.udpipe")
model_sp <- udpipe::udpipe_load_model("data-raw/spanish-gsd-ud-2.4-190531.udpipe")

usethis::use_data(model_en, overwrite = TRUE)
usethis::use_data(model_sp, overwrite = TRUE)
