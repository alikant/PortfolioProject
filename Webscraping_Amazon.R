######################################
######## Importing Libraries ######## 
#####################################

library(tidyverse)
library(rvest)

######################################
############ Web Scraping ########### 
#####################################

url = "https://www.amazon.com/Fixtur-Wooden-Wireless-Charging-Station/dp/B0BW4ZB1LJ/ref=sr_1_1_sspa?qid=1684400058&s=electronics&sr=1-1-spons&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUFYNjdVWUNWT0VYRTImZW5jcnlwdGVkSWQ9QTAzMDAzNDBPVTJTVldUTUlSUEwmZW5jcnlwdGVkQWRJZD1BMDk0MzU0NDIyRDRaSEpQUFpCWTYmd2lkZ2V0TmFtZT1zcF9hdGZfYnJvd3NlJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ&th=1"

## Parse the HTML code
web_page <- read_html(url)
web_page

# Extracting the name of the product
product_name <- web_page %>% 
  html_element("#productTitle") %>% 
  html_text2()

# Extracting the brand of the product
brand <- web_page %>% 
  html_element(".po-brand .po-break-word") %>%
  html_text2()

# Extracting the star-rating for consumers' behavior analysis
star_rating <- web_page %>% 
  html_element("span.a-icon-alt") %>% 
  html_text2()

# Extracting the price of the product
price <- web_page %>% 
  html_element("span.a-offscreen") %>% 
  html_text2()

# Remove the dollar sign ($)
price_nondollar <- gsub("\\$", "", price)

# Convert price to numeric
price <- as.numeric(price_nondollar)

# Extracting all tables (Exploring tables of the page)
tables_webpage <- web_page %>% 
  html_elements("table") %>% 
  html_table()

# Amazon Global Shipping cost
shipping_element <- web_page %>% 
  html_element("span.a-size-base.a-color-secondary") %>% 
  html_text2()

# Extract the shipping cost value using regular expressions
shipping_cost <- stringr::str_extract(shipping_element, "\\$[0-9.]+")

# Remove the dollar sign ($)
shipping_cost <- gsub("\\$", "", shipping_cost)

# Convert the shipping cost to numeric
shipping_cost <- as.numeric(shipping_cost)

# Total price (without Import Fee Deposit)
total_price <- price +shipping_cost; total_price

#####################################
###### Putting it all Together ######
#####################################

# Merge elements
data_collection <- tibble(product_name, brand, star_rating, price, shipping_cost, total_price)

# Convert our data to data frame
data_collection <- as.data.frame(data_collection)

# Take a look at the data
glimpse(data_collection)
View(data_collection)

#####################################
######### Scrape an archive #########
#####################################

# The Page of Cell Phones and Accessories
html <- read_html("https://www.amazon.com/s?i=specialty-aps&bbn=16225009011&rh=n%3A%2116225009011%2Cn%3A2811119011&ref=nav_em__nav_desktop_sa_intl_cell_phones_and_accessories_0_2_5_5")

# Extracting all URLs on the page
products_urls <- html %>% 
  html_elements(".s-line-clamp-4 a") %>% 
  html_attr("href")

# Looking at the first five elements 
head(products_urls,5)

# Changing the local links to the global links
products_urls <- paste("https://amazon.com", products_urls, sep="")
head(products_urls,5)

###########################################
######### Amazon Scraper Function #########
###########################################

scraper_amazon <- function(products_url) {
  message('Scraping URL: ', products_url)
  
  # Elements Extraction
  web_page <- read_html(products_url)
  product_name <- web_page %>% html_element("#productTitle") %>% html_text2()
  brand <- web_page %>% html_element(".po-brand .po-break-word") %>% html_text2()
  star_rating <- web_page %>% html_element("span.a-icon-alt") %>% html_text2()
  price <- web_page %>% html_element("span.a-offscreen") %>% html_text2()
  shipping_element <- web_page %>% html_element("span.a-size-base.a-color-secondary") %>% html_text2()
  
  # Convert the price to numeric 
  price_nondollar <- gsub("\\$", "", price)
  price <- as.numeric(price_nondollar)
  
  # Convert the shipping cost to numeric
  shipping_cost <- stringr::str_extract(shipping_element, "\\$[0-9.]+")
  shipping_cost <- gsub("\\$", "", shipping_cost)
  shipping_cost <- as.numeric(shipping_cost)
  
  # Total price (without Import Fee Deposit)
  total_price <- price +shipping_cost; total_price
  
  # Putting all together
  data_collection <- tibble(product_name, brand, star_rating, price, shipping_cost, total_price)
  
  # Convert our data to data frame
  data_collection <- as.data.frame(data_collection)
  
  # Show the data frame of the results
  print(data_collection)
}

############################################
######### Loop over Amazon Scraper #########
############################################

# Specify the page 
html <- read_html("https://www.amazon.com/s?i=specialty-aps&bbn=16225009011&rh=n%3A%2116225009011%2Cn%3A2811119011&ref=nav_em__nav_desktop_sa_intl_cell_phones_and_accessories_0_2_5_5")

# Extracting all URLs on the specified page
products_urls <- html %>% 
  html_elements(".s-line-clamp-4 a") %>% 
  html_attr("href")

# Convert to list to use indices in a loop
products_urls <- as.list(products_urls)

# Convert the local links to the global links
products_urls <- paste("https://amazon.com", products_urls, sep="")
print(products_urls)

# Loop over the scraper_function for all URLs on the page
results <- list()
for (i in seq_along(products_urls)) {
  results[[i]] = scraper_amazon(products_urls[[i]])
}

# Convert to data frame
mydata <- as.data.frame(bind_rows(results, .id = 'url'))
View(mydata)

# Renaming the script file
file.rename("webscraping.R","Webscraping_Amazon")
