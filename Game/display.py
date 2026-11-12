# This module is for all display related functions
# It will later include images

import pygame

# Set background colors RGB
SKY_BLUE = (190, 230, 255)
OCEAN_BLUE = (30, 144, 255)
SAND_YELLOW = (194, 178, 128)

# Fractions of the screen height (0.0 = top, 1.0 = bottom)
HORIZON = 0.42    # water starts 42% of the way down
SAND = 0.05       # sand is the bottom 5% of the screen

# Score Font global variable
score_font = None

def setup_fonts():
    global score_font
    score_font = pygame.font.SysFont("trebuchetms", 36, bold=True) # font type and size

def get_horizon(screen):
    return int(screen.get_height() * HORIZON)

def get_sand_top(screen):
    return int(screen.get_height() * (1 - SAND))

#Autoupdate: This function draws the background of the game, including the sky, ocean, and sand.
def draw_background(screen):
    width = screen.get_width()
    height = screen.get_height()
    horizon = get_horizon(screen)
    sand_top = get_sand_top(screen)

    screen.fill(SKY_BLUE)
    pygame.draw.rect(screen, OCEAN_BLUE,  (0, horizon, width, sand_top - horizon))
    pygame.draw.rect(screen, SAND_YELLOW, (0, sand_top, width, height - sand_top))

def get_band(screen, tier):
    water_top = get_horizon(screen)
    water_bottom = get_sand_top(screen)
    third = (water_bottom - water_top) // 3

    index = {"small": 0, "medium": 1, "large": 2}[tier]
    band_top = water_top + index * third
    return band_top, band_top + third

def load_image(filename, height):
    img = pygame.image.load("Images/" + filename).convert_alpha()
    w, h = img.get_size()
    return pygame.transform.smoothscale(img, (int(w * height / h), height))

def draw_scoreboard(screen, score):
    # Make a rectangle for the board and pin its top-right corner near the screen's top-right
    board = pygame.Rect(0, 0, 190, 65)
    board.topright = (screen.get_width() - 20, 20)

    # Draw the oval and its outline inside that rectangle
    pygame.draw.ellipse(screen, (220, 245, 255), board)
    pygame.draw.ellipse(screen, (60, 130, 170), board, 3)

    # Draw the score text in the center of the board
    score_text = score_font.render("Score: " + str(score), True, (35, 75, 100))
    score_rect = score_text.get_rect(center=board.center)
    screen.blit(score_text, score_rect)