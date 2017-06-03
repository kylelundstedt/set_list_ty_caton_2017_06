library(googlesheets)
library(httr)
library(rvest)
library(stringr)
library(tidyverse)

# connect to Google Sheets
(my_sheets <- gs_ls())
# connect to Loosely Covered Set Lists workbook
set_lists <- gs_title("LC Gigs Set Lists")

# connect to gig-specific tab in that workbook
gig_name <- "2017-06 Ty Caton"
set_list <- set_lists %>% gs_read(ws = gig_name) %>%
  mutate( Artist = str_replace_all(Artist, "/", "-") ) %>%
  mutate( Artist = str_replace_all(Artist, "’" , "") ) %>%
  mutate( Artist = str_replace_all(Artist, "'", "") ) %>%
  mutate( Artist = str_replace_all(Artist, "&", "n") ) %>%
  mutate( Artist = str_replace_all(Artist, "\\.", "") ) %>%
  mutate( Title = str_replace_all(Title, "/", "-") ) %>%
  mutate( Title = str_replace_all(Title, "’" , "") ) %>%
  mutate( Title = str_replace_all(Title, "'", "") ) %>%
  mutate( Title = str_replace_all(Title, "&", "n") ) %>%
  mutate( Title = str_replace_all(Title, "\\.", "") ) %>%
  mutate( Artist_Title =
           str_c("https://www.songlyrics.com/", Artist, "/", Title, "-lyrics/") ) %>% 
  mutate( Artist_Title = str_to_lower(Artist_Title) ) %>% 
  mutate( Artist_Title = str_replace_all(Artist_Title, "\\s+", "-") ) %>% 
  mutate( Title_dash = str_replace_all(Title, " ", "-"))

# create RMarkdown file for gig-specific Lead Sheets
bookfilename <- str_c('book_filename: "', gig_name, '"\n', 'rmd_files: [')
write(bookfilename, file = "_bookdown.yml")
songs <- paste0('\t"lead_sheets/',
                 set_list$Title_dash,
                 '.Rmd",')
write(songs, file = "_bookdown.yml", append = TRUE)
outputs <- paste0('\n]\n',
                 'output_dir: docs')
write(outputs, file = "_bookdown.yml", append = TRUE)
