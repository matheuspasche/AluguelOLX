library(tidyverse)
library(rvest)

desapega <- function(x){ 
  x %>% 
    read_html() %>% 
    html_nodes(xpath = '//*[@id="content"]') %>% 
    map_df(~{
      bind_cols(
        tibble(
          tibble(
            name = 
              c(
                "Título",
                "Aluguel",
                'Data',
                html_nodes(.x,"dt") %>% html_text() 
              ))%>% filter(!name %in% c("Categoria", 'Tipo', 'Quartos' )),
          
          value = 
            c(
              html_nodes(.x, xpath = 'div[2]/div/div[2]/div[1]/div[14]/div/div/h1') %>% html_text(), #Titulo
              html_nodes(.x, xpath = 'div[2]/div/div[2]/div[1]/div[12]/div/div/div/div/div[1]/div/h2') %>% html_text(),
              html_nodes(.x,xpath =  "div[2]/div/div[2]/div[1]/div[28]/div/div/div/span[1]") %>% html_text(),
              html_nodes(.x,"dd") %>% html_text()
              
            )
          
        )
      ) %>% 
        pivot_wider()
    }
    )
}
loc.url <- 
  map(
    map_chr(1:3, 
            ~paste0("https://rj.olx.com.br/rio-de-janeiro-e-regiao/zona-norte/tijuca-e-regiao/imoveis/aluguel/apartamentos?o=",
                    .x,"&pe=1500&ros=2", collapse = "")), ~
        rvest::read_html(.x) %>%
        html_nodes(xpath = paste0('//*[@id="ad-list"]')) %>% 
        html_nodes(css = "li > a") %>% 
        map_chr(~.x %>% html_attr('href')) 
  ) %>%
  flatten_chr()


Dados <- loc.url%>% map_df(possibly(desapega, NULL)) %>% 
         mutate(href = loc.url)%>% 
  mutate(across(c(`Aluguel`, `Condomínio`, `IPTU`), ~ as.numeric(gsub("[\\R$.]", "", .x)))) %>% 
  mutate(`Área útil` = as.numeric(gsub("[\\m²]", "", `Área útil`))) %>% 
  mutate(across(c(`Aluguel`, `Condomínio`, `IPTU`), ~replace_na(.x, 0))) %>% 
  mutate(Total = `Aluguel` + `Condomínio`+ `IPTU`, .after = IPTU ) %>% 
  filter(Total < 1900, Bairro %in% c('Tijuca','Vila Isabel')) 

reticulate::source_python('1 - ZipCode.py')
