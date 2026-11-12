# This module is for all display related functions
# It will later include images

import pygame

# Import Images
fisherman_image = pygame.image.load("Game/images/Fisherman.png")

# Resize Images
fisherman_image = pygame.transform.scale(fisherman_image, (169, 135))

# Set background colors RGB
SKY_BLUE = (190, 230, 255)
OCEAN_BLUE = (120, 195, 235)
SAND_YELLOW = (194, 178, 128)

# Set the height of colors
SKY_HEIGHT = 300
WATER_HEIGHT = 300 
SAND_HEIGHT = 100

# Score Font global variable
score_font = None

def setup_fonts():
    global score_font
    score_font = pygame.font.SysFont("trebuchetms", 36, bold=True) # font type and size

def draw_background(screen):
    # Draw the sky
    screen.fill(SKY_BLUE)

    # Draw the water
    pygame.draw.rect(screen, OCEAN_BLUE, (0, SKY_HEIGHT, 1000, WATER_HEIGHT))

    # Draw the ocean floor
    pygame.draw.rect(screen, SAND_YELLOW, (0, SKY_HEIGHT + WATER_HEIGHT, 1000, SAND_HEIGHT))

def draw_boat_and_fisherman(screen):
    # Draw the boat
    screen.blit(fisherman_image, (390, 185))

def draw_scoreboard(screen, score):
    # Draw oval scoreboard
    pygame.draw.ellipse(screen, (220, 245, 255), (775, 20, 190, 65))
    pygame.draw.ellipse(screen, (60, 130, 170), (775, 20, 190, 65), 3)

    # Draw the score
    score_text = score_font.render("Score: " + str(score), True, (35, 75, 100))
    score_rect = score_text.get_rect(center=(870, 52))
    screen.blit(score_text, score_rect)