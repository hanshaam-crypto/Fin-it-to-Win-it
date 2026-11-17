# This module is for all display related functions

import pygame
import sprites

BOAT_SCALE = 5

# Image initialization
fisherman_image = None
boat_image_right = None
boat_image_left = None

# Background colors (R, G, B)
SKY_BLUE    = (190, 230, 255)
OCEAN_BLUE  = (120, 195, 235)
SAND_YELLOW = (194, 178, 128)

# Fractions of the screen height (0.0 = top, 1.0 = bottom)
HORIZON = 0.42    # water starts 42% of the way down
SAND = 0.05       # sand is the bottom 12% of the screen

def get_horizon(screen):
    return int(screen.get_height() * HORIZON)

def get_sand_top(screen):
    return int(screen.get_height() * (1 - SAND))

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

def load_image(filename):
    return sprites.get_sprite(filename)

def setup_images():
    global fisherman_image, boat_image_right, boat_image_left

    # The boat sprite faces left, and we make a mirrored copy that faces right
    fisherman_image = sprites.make_sprite(sprites.BOAT, sprites.BOAT_PAL, BOAT_SCALE)
    boat_image_right = fisherman_image
    boat_image_left = pygame.transform.flip(fisherman_image, True, False)

def draw_fisherman(screen, boat_x, boat_direction):
    # Moving right: use the mirrored picture (faces right)
    if boat_direction == 1:
        image = boat_image_left
    else:
        image = boat_image_right

    boat_rectangle = image.get_rect(midbottom=(boat_x, get_horizon(screen) + 18))
    screen.blit(image, boat_rectangle)