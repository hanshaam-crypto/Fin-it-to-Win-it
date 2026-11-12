# This module is for all display related functions

import pygame
import random # for randomizing the treasurechest positions

# Image initialization
fisherman_image = None
treasure_chest_image = None
treasure_chest_x = None
boat_image_right = None
boat_image_left = None

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
    global treasure_chest_image
    global boat_image_right, boat_image_left

    orange_coral_image = pygame.image.load("Game/images/OrangeCoral.png").convert_alpha()
    pink_coral_image = pygame.image.load("Game/images/PinkCoral.png").convert_alpha()
    red_coral_image = pygame.image.load("Game/images/RedCoral.png").convert_alpha()
    treasure_chest_image = pygame.image.load("Game/images/TreasureChest.png").convert_alpha()

    fisherman_image = pygame.image.load("Game/images/Fisherman.png").convert_alpha()

    # Fade the bottom edge into the water
    fade_height = 40

    for y in range(fisherman_image.get_height() - fade_height, fisherman_image.get_height()):
        for x in range(fisherman_image.get_width()):
            r, g, b, a = fisherman_image.get_at((x, y))
            new_alpha = int(a * (fisherman_image.get_height() - y) / fade_height)
            fisherman_image.set_at((x, y), (r, g, b, new_alpha))

    # Create the boat facing both directions
    boat_image_right = fisherman_image
    boat_image_left = pygame.transform.flip(fisherman_image, True, False)

def draw_fisherman(screen, boat_x, boat_direction):

    # Resize based on screen height
    height = int(screen.get_height() * 0.15)

    # Choose image based on boat direction
    if boat_direction == 1:
        image = boat_image_left
    else:
        image = boat_image_right

    image_width, image_height = image.get_size()

    resized_image = pygame.transform.smoothscale(
        image, (int(image_width * height / image_height), height)
    )

    # Position based on boat's horizontal position and waterline
    boat_rectangle = resized_image.get_rect(
        midbottom=(boat_x, get_horizon(screen) + 18)
    )

    screen.blit(resized_image, boat_rectangle)

def draw_treasure_chest(screen):
    global treasure_chest_x

    # Resize treasure chest
    chest_height = 70

    image_width, image_height = treasure_chest_image.get_size()

    resized_image = pygame.transform.smoothscale(
        treasure_chest_image,
        (int(image_width * chest_height / image_height), chest_height)
    )

    # Randomize horizontal position when the game starts
    if treasure_chest_x is None:
        half_width = resized_image.get_width() // 2
        treasure_chest_x = random.randint(
            half_width, screen.get_width() - half_width
        )

    # Position treasure chest
    chest_rectangle = resized_image.get_rect(
        midbottom=(treasure_chest_x, get_sand_top(screen) + 15)
    )

    screen.blit(resized_image, chest_rectangle)

# def draw_obstacles(screen):