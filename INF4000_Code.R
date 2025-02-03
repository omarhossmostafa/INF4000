# Created by Omar Mostafa - INF4000 January 2025
# Load necessary libraries
library(dplyr)
library(lubridate)
library(zoo)
library(ggplot2)
library(reshape2)
library(viridis)
library(scales)


# Load the dataset
results_data <- read.csv("results.csv")

# Convert 'date' to Date type and extract the year
results_data <- results_data %>%
  mutate(
    date = as.Date(date),
    year = year(date),
    goal_diff = home_score - away_score
  )

# Count and print missing data before cleaning
missing_data_count <- sum(is.na(results_data))
print(paste("Total missing values in dataset:", missing_data_count))
print(paste("Total entries before removing missing data:", nrow(results_data)))

# Remove rows with missing data
results_data <- results_data %>% na.omit()

# Print total entries after removing missing values
print(paste("Total entries after removing missing data:", nrow(results_data)))

# Extract unique country names from home and away teams
all_countries <- unique(c(results_data$home_team, results_data$away_team))

# Define continent mapping for countries
continent_mapping <- data.frame(
  country = c(
    #Africa
    "Algeria", "Ambazonia", "Angola", "Barawa", "Benin", "Biafra", "Botswana", "Burkina Faso",
    "Burundi", "Cameroon","Canary Islands", "Cape Verde", "Central African Republic", "Chad", "Chagos Islands",
    "Comoros", "Congo", "DR Congo", "Darfur", "Djibouti", "Egypt", "Equatorial Guinea",
    "Eritrea", "Eswatini", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau",
    "Ivory Coast", "Kabylia", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi",
    "Mali", "Matabeleland", "Mauritania", "Mauritius", "Mayotte", "Morocco", "Mozambique",
    "Namibia", "Niger", "Nigeria","Réunion", "Rwanda","Saint Helena","Senegal", "Seychelles", "Sierra Leone", "Somalia",
    "Somaliland", "South Africa", "South Sudan", "Sudan", "São Tomé and Príncipe", "Tanzania",
    "Togo", "Tunisia", "Uganda", "Western Sahara", "Yoruba Nation", "Zambia", "Zanzibar", "Zimbabwe",
    
    # Asia
    "Afghanistan", "Armenia", "Arameans Suryoye", "Artsakh", "Azerbaijan", "Bahrain", "Bangladesh", "Bhutan", "Brunei",
    "Burma","Cambodia", "Chechnya", "China PR", "Cyprus", "Donetsk PR", "East Timor", "Georgia","Hong Kong","India",
    "Indonesia", "Iran", "Iraq", "Iraqi Kurdistan", "Israel", "Japan", "Jordan", "Kazakhstan",
    "Kuwait", "Kyrgyzstan", "Laos", "Lebanon", "Luhansk PR","Macau", "Malaya" ,"Malaysia", "Maldives", "Manchukuo",
    "Mongolia", "Myanmar", "Nepal", "North Korea", "North Vietnam", "Oman", "Pakistan", "Palestine",
    "Panjab", "Philippines", "Qatar", "Ryūkyū", "Saudi Arabia", "Singapore", "South Korea", "South Yemen",
    "South Ossetia", "Sri Lanka", "Syria", "Taiwan", "Tajikistan", "Tamil Eelam", "Thailand",
    "Tibet", "Timor-Leste", "Turkey", "Turkmenistan", "United Arab Emirates", "United Koreans in Japan",
    "Uzbekistan", "Vietnam", "Vietnam Republic","West Papua", "Yemen", "Yemen DPR" , 
    
    # Europe
    "Abkhazia", "Albania", "Alderney", "Andalusia", "Andorra", "Asturias", "Austria", "Basque Country",
    "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Catalonia", "Central Spain", "Chameria", "Cilento",
    "Corsica", "Crimea", "Croatia", "Czech Republic","Czechoslovakia", "Denmark", "Délvidék", "England","Elba Island", "Estonia",
    "Faroe Islands", "Felvidék", "Finland", "France", "Franconia","Găgăuzia", "Galicia", "German DR",
    "Germany", "Gibraltar","Gotland","Gozo", "Greece", "Guernsey", "Hungary", "Iceland", "Ireland", "Isle of Man",
    "Isle of Wight", "Italy", "Jersey", "Kernow", "Kosovo", "Kárpátalja", "Latvia", "Liechtenstein", "Lithuania",
    "Luxembourg", "Madrid", "Malta","Menorca","Moldova", "Monaco", "Montenegro", "Netherlands","Northern Cyprus",  
    "Northern Ireland","North Macedonia", "Norway", "Occitania", "Padania", "Poland", "Portugal", "Provence",
    "Raetia", "Republic of Ireland","Republic of St. Pauli", "Romania","Romani people", "Russia", "Saare County", "Saarland",
    "San Marino", "Sark","Saugeais", "Scotland", "Sealand", "Seborga", "Serbia", "Shetland", "Silesia",
    "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Székely Land", "Sápmi",
    "Ticino","Two Sicilies", "Ukraine", "United Kingdom", "Vatican City", "Wales", "Western Armenia",
    "Western Isles", "Ynys Môn", "Yorkshire", "Yugoslavia", "Åland Islands",
    
    # North America
    "Anguilla", "Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Bermuda", "Bonaire",
    "British Virgin Islands", "Brittany", "Canada", "Cascadia", "Cayman Islands", "Costa Rica",
    "County of Nice", "Cuba", "Curaçao", "Dominica", "Dominican Republic", "El Salvador",
    "Ellan Vannin", "Greenland", "Grenada", "Guadeloupe", "Guatemala", "Haiti", "Honduras",
    "Jamaica", "Martinique", "Mexico", "Montserrat", "Nicaragua", "Panama", "Parishes of Jersey",
    "Puerto Rico", "Saint Barthélemy", "Saint Kitts and Nevis", "Saint Lucia", "Saint Martin",
    "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Sint Maarten",
    "Surrey", "Trinidad and Tobago", "Turks and Caicos Islands", "United States",
    "United States Virgin Islands",
    
    # South America
    "Argentina","Aruba", "Aymara", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador","Falkland Islands", "French Guiana",
    "Guyana", "Mapuche", "Maule Sur", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela",
    
    # Oceania
    "American Samoa", "Australia", "Cook Islands", "Fiji", "Frøya", "Guam", "Hitra", "Hmong",
    "Kiribati", "Micronesia", "New Caledonia", "New Zealand", "Niue","Northern Mariana Islands", "Orkney", "Palau",
    "Papua New Guinea", "Rhodes", "Samoa", "Solomon Islands", "Tahiti", "Tonga", "Tuvalu",
    "Vanuatu", "Wallis Islands and Futuna", "Western Australia", "Western Samoa"
  ),
  continent = c(
    rep("Africa", 69),
    rep("Asia", 72),
    rep("Europe", 105),
    rep("North America", 47),
    rep("South America", 18),
    rep("Oceania", 27)
  )
)
# Merge continent data with dataset
results_data <- results_data %>%
  left_join(continent_mapping, by = c("home_team" = "country"))

# Ensure all rows have assigned continents
results_data <- results_data %>% filter(!is.na(continent))
# --------------------------------------------------
# Chart 1: 
# Define function to categorize years into 30-year intervals
categorize_year <- function(year) {
  if (year >= 1930 & year <= 1959) {
    return("1930-1959")
  } else if (year >= 1960 & year <= 1989) {
    return("1960-1989")
  } else if (year >= 1990 & year <= 2019) {
    return("1990-2019")
  } else {
    return("2020-Present")
  }
}

# Apply function to create year intervals
wc_qualifiers_performance <- results_data %>%
  filter(tournament == world_cup_qualifiers, neutral == FALSE) %>%
  mutate(year_category = sapply(year, categorize_year)) %>%
  group_by(continent, year_category) %>%
  summarise(
    win_rate = sum(home_score > away_score, na.rm = TRUE) / n(),
    total_games = n()
  ) %>%
  filter(total_games > 20)  # Remove groups with very few matches

# Stacked Bar Chart: Home Win Rates in World Cup Qualifiers by Continent (Grouped by 30-Year Intervals)
ggplot(wc_qualifiers_performance, aes(x = continent, y = win_rate, fill = year_category)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Home Win Rates in FIFA World Cup Qualifiers by Continent (30-Year Intervals)",
    x = "Continent",
    y = "Home Win Rate",
    fill = "Year Interval"
  ) +
  theme_minimal()

# ------------------------------------------
# Chart 2
# ------------------------------------------

# Ensure continent column has no unexpected values
strongest_home_teams <- results_data %>%
  filter(neutral == FALSE) %>%  # Only consider home matches
  group_by(home_team, continent) %>%
  summarise(
    win_rate = sum(home_score > away_score, na.rm = TRUE) / n(),  # Calculate home win rate
    total_games = n()  # Count number of home games
  ) %>%
  filter(total_games > 50) %>%  # Only consider teams with at least 200 home games
  arrange(desc(win_rate))  # Sort teams by highest home win rate

# Manually select only specific teams for labeling
selected_teams <- strongest_home_teams %>%
  filter(home_team %in% c("Brazil", "England", "Argentina", "Germany", "Egypt", 
                          "San Marino", "Iran", "Spain", "Sweden", "France",
                          "United States", "South Korea", "Australia"))

# Scatter Plot: Strongest Home Teams with Labels for Selected Countries
ggplot(strongest_home_teams, aes(x = total_games, y = win_rate, color = continent)) +
  geom_point(size = 2.5, alpha = 0.7) +
  geom_text(data = selected_teams, aes(label = home_team), vjust = -1, size = 3, fontface = "bold") +
  labs(
    title = "Strongest Home Teams Based on Win Rate",
    x = "Total Home Games Played",
    y = "Home Win Rate",
    color = "Continent"
  ) +
  theme_minimal()
# ------------------------------------------
# Chart 3
# ------------------------------------------
# Prepare data labels to show total games played
away_performance <- away_performance %>%
  mutate(label = paste0("N = ", total_games))

# Lollipop Chart for Away Performance
ggplot(away_performance, aes(x = away_in_same_continent, y = win_rate, color = away_in_same_continent)) +
  geom_segment(aes(x = away_in_same_continent, xend = away_in_same_continent, y = 0, yend = win_rate), size = 1) +
  geom_point(size = 6) +
  geom_text(aes(label = label), vjust = -1, size = 5) +  # Move labels up
  ylim(0, max(away_performance$win_rate) + 0.05) +  # Add extra space above the highest point
  labs(
    title = "Impact of Playing Away in a Different Continent vs. Same Continent",
    x = "Away Match Type",
    y = "Win Rate",
    color = "Match Type"
  ) +
  theme_minimal()

# ------------------------------------------
# Chart 4 
# ------------------------------------------
# Ensure both home and away teams have assigned continents
results_data <- results_data %>%
  left_join(continent_mapping, by = c("home_team" = "country"), suffix = c("_home", "_away"))

# Identify matches where teams played in their home continent but not in their home country
home_continent_matches <- results_data %>%
  filter(neutral == FALSE) %>%
  mutate(
    home_continent_but_not_home_country = ifelse(continent_home == continent_away & home_team != country, 
                                                 "Home Continent (Not Home Country)", 
                                                 "Regular Home Match")
  )

# Calculate win, loss, and draw rates
home_continent_performance <- home_continent_matches %>%
  group_by(home_continent_but_not_home_country) %>%
  summarise(
    wins = sum(home_score > away_score, na.rm = TRUE),
    losses = sum(home_score < away_score, na.rm = TRUE),
    draws = sum(home_score == away_score, na.rm = TRUE),
    total_games = n()
  ) %>%
  mutate(
    `Win Rate` = wins / total_games,
    `Loss Rate` = losses / total_games,
    `Draw Rate` = draws / total_games
  ) %>%
  pivot_longer(cols = c(`Win Rate`, `Loss Rate`, `Draw Rate`), names_to = "result", values_to = "rate") %>%
  mutate(label = ifelse(result == "Win Rate", paste0("N = ", total_games), NA))  # Only show label on Win Rate

# Stacked Bar Chart for Home Continent Matches with Proper Legend Labels
ggplot(home_continent_performance, aes(x = home_continent_but_not_home_country, y = rate, fill = result)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 5, fontface = "bold") +  # Add total game count in bars
  labs(
    title = "Performance of Teams Playing at Home Continent But Not Home Country",
    x = "Match Type",
    y = "Proportion of Matches",
    fill = "Match Result"
  ) +
  theme_minimal()
# ------------------------------------------
# Chart 5
# ------------------------------------------
# 5. Away Team Performance by Continent (Heatmap)
# Recalculate Away Win Rate by Continent
away_win_by_continent <- results_data %>%
  filter(neutral == FALSE) %>%
  group_by(continent_home, continent_away) %>%
  summarise(
    away_win_rate = sum(away_score > home_score, na.rm = TRUE) / n()
  )

# Function to determine font color based on background brightness
get_text_color <- function(value) {
  ifelse(value > 0.38, "white", "black")  # Darker backgrounds get white text, lighter backgrounds get black text
}

# Add a new column for text color based on away win rate
away_win_by_continent <- away_win_by_continent %>%
  mutate(text_color = get_text_color(away_win_rate))

# Heatmap: Away Team Performance by Continent with Adaptive Text Color
ggplot(away_win_by_continent, aes(x = continent_home, y = continent_away, fill = away_win_rate)) +
  geom_tile(color = "white") +
  geom_text(aes(label = scales::percent(away_win_rate, accuracy = 0.1), color = text_color), size = 5, fontface = "bold") +  # Add adaptive text color
  scale_fill_viridis(option = "magma", direction = -1, name = "Away Win Rate", labels = scales::percent) +
  scale_color_identity() +  # Ensures manual color assignment works properly
  labs(
    title = "Away Team Win Rate by Continent (Fully Accessible Color Scheme)",
    x = "Home Team Continent",
    y = "Away Team Continent",
    fill = "Away Win Rate"
  ) +
  theme_minimal()
#-------------------------------------------
# Chart 6 
# ------------------------------------------
# Calculate the frequency of intercontinental matches (excluding same-continent matchups)
match_frequency_by_continent <- results_data %>%
  filter(neutral == FALSE, continent_home != continent_away) %>%  # Exclude same-continent matches
  group_by(continent_home, continent_away) %>%
  summarise(match_count = n())

# Histogram: Frequency of Intercontinental Matches
ggplot(match_frequency_by_continent, aes(x = continent_home, y = match_count, fill = continent_away)) +
  geom_bar(stat = "identity", position = "dodge") +  # Grouped bar chart
  labs(
    title = "Frequency of Intercontinental Matches",
    x = "Home Team Continent",
    y = "Number of Matches",
    fill = "Away Team Continent"
  ) +
  theme_minimal()
