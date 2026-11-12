# This module is for all display related functions

import pygame

# Decorative Images
orange_coral_image = None
pink_coral_image = None
red_coral_image = None
fisherman_image = None

# Set background colors RGB
SKY_BLUE = (190, 230, 255)
OCEAN_BLUE = (120, 195, 235)
SAND_YELLOW = (194, 178, 128)

# Fractions of the screen height (0.0 = top, 1.0 = bottom)
HORIZON = 0.42    # water starts 42% of the way down
SAND = 0.05       # sand is the bottom 5% of the screen

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
    img = pygame.image.load("Game/images/" + filename).convert_alpha()
    w, h = img.get_size()
    return pygame.transform.smoothscale(img, (int(w * height / h), height))

def setup_images():

    global orange_coral_image, pink_coral_image
    global red_coral_image, fisherman_image

    orange_coral_image = pygame.image.load("Game/images/OrangeCoral.png").convert_alpha()
    pink_coral_image = pygame.image.load("Game/images/PinkCoral.png").convert_alpha()
    red_coral_image = pygame.image.load("Game/images/RedCoral.png").convert_alpha()

    fisherman_image = pygame.image.load("Game/images/Fisherman.png").convert_alpha()
    # Fade the bottom edge into the water
    fade_height = 40

    for y in range(fisherman_image.get_height() - fade_height, fisherman_image.get_height()):
        for x in range(fisherman_image.get_width()):
            r, g, b, a = fisherman_image.get_at((x, y))
            new_alpha = int(a * (fisherman_image.get_height() - y) / fade_height)
            fisherman_image.set_at((x, y), (r, g, b, new_alpha))

def draw_fisherman(screen):

    # Resize based on screen height (15% of screen height)
    height = int(screen.get_height() * 0.15)

    w, h = fisherman_image.get_size()

    resized_image = pygame.transform.smoothscale(
        fisherman_image, (int(w * height / h), height)
    )

    # Position based on screen width and horizon
    fisherman_rect = resized_image.get_rect(
        midbottom=(screen.get_width() // 2, get_horizon(screen) + 18)
    )

    screen.blit(resized_image, fisherman_rect)

# def draw_treasure_cheast(screen):

# def draw_entity(screen):

# def draw_obstacles(screen):

def draw_decorations(screen):
    width = screen.get_width()
    height = screen.get_height()

    sand_top = get_sand_top(screen)

    # Coral positions based on screen size
    orange_x = int(width * 0.05)
    pink_x = int(width * 0.40)
    red_x = int(width * 0.75)

    coral_y = int(sand_top - 20)

   # Position coral along the bottom of the screen
    orange_rect = orange_coral_image.get_rect(midbottom=(orange_x, height))
    pink_rect = pink_coral_image.get_rect(midbottom=(pink_x, height))
    red_rect = red_coral_image.get_rect(midbottom=(red_x, height))

    # Draw the coral images
    screen.blit(orange_coral_image, orange_rect)
    screen.blit(pink_coral_image, pink_rect)
    screen.blit(red_coral_image, red_rect)