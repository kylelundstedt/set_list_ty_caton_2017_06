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
  mutate( Artist = str_replace_all(Artist, "&", "") ) %>%
  mutate( Artist_Title =
           str_c("https://www.songlyrics.com/", Artist, "/", Title, "-lyrics/") ) %>% 
  mutate( Artist_Title = str_to_lower(Artist_Title) ) %>% 
  mutate( Artist_Title = str_replace_all(Artist_Title, "\\s+", "-") )
# create RMarkdown file for gig-specific Lead Sheets
???

bookfilename <- str_c('book_filename: "', gig_name, '"\n', 'rmd_files: [')
write(bookfilename, file = "_bookdown.yml")
songs <- paste0('\t"',
                 set_list$Title,
                 '",')
write(songs, file = "_bookdown.yml", append = TRUE)
outputs <- paste0('\n]\n',
                 'output_dir: docs')
write(outputs, file = "_bookdown.yml", append = TRUE)

html <- read_html(song_url)
lyrics <- html %>%
  html_nodes("#songLyricsDiv") %>%
  html_text() %>%
  str_replace_all("\n", "  \n") %>% 
  str_replace_all("[\r]", "") %>% 
  str_replace_all(c("€" = "", "â" = "", "½" = "", "" = ""))
section <- paste0("# ", song_title, "\n")
write(section, file = paste0("./", song_title, ".Rmd"))
write(lyrics, file = paste0("./", song_title, ".Rmd"),
      append = TRUE)

# create RMarkdown file for Master Lead Sheets
rmd <- list.files(path = "./Songs", pattern = '\\.md')
chunks <- paste0("# ",
                 tools::file_path_sans_ext(rmd),
                 "\n```{r child = \"./Songs/", rmd, "\"}\n```\n\\clearpage\n")
write(chunks, "chunks.Rmd")
system("cat header.txt chunks.Rmd > Lead_Sheets_2017-05_Master.Rmd")
