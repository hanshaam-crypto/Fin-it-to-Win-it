# This module is for all display related functions

import pygame

# Import Images
fisherman_image = pygame.image.load("Game/images/Fisherman.png")
greyfish_image = pygame.image.load("Game/images/GreyFish.png")

# Resize Images
fisherman_image = pygame.transform.smoothscale(fisherman_image, (169, 135))
# Fade the bottom edge of the image into the water
for y in range(fisherman_image.get_height() - 12, fisherman_image.get_height()):
    for x in range(fisherman_image.get_width()):
        r, g, b, a = fisherman_image.get_at((x, y))
        new_alpha = int(a * (fisherman_image.get_height() - y) / 12)
        fisherman_image.set_at((x, y), (r, g, b, new_alpha))

greyfish_image = pygame.transform.smoothscale(greyfish_image, (76, 49))

# Object Movement
greyfish_x = 0
greyfish_y = 315
greyfish_speed = 0.15


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

def draw_fish(screen):
    global greyfish_x

    # Move the fish to the right
    greyfish_x = greyfish_x + greyfish_speed

    # Restart fish on the left once it leaves the screen
    if greyfish_x > 1000:
        greyfish_x = -76

    # Draw the fish
    screen.blit(greyfish_image, (greyfish_x, greyfish_y))

def draw_scoreboard(screen, score):
    # Draw oval scoreboard
    pygame.draw.ellipse(screen, (220, 245, 255), (775, 20, 190, 65))
    pygame.draw.ellipse(screen, (60, 130, 170), (775, 20, 190, 65), 3)

    # Draw the score
    score_text = score_font.render("Score: " + str(score), True, (35, 75, 100))
    score_rect = score_text.get_rect(center=(870, 52))
    screen.blit(score_text, score_rect)