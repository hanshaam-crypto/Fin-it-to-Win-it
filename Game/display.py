# This module is for all display related functions
# It will later include images

import pygame

# Set background colors RGB
SKY_BLUE = (190, 230, 255)
OCEAN_BLUE = (30, 144, 255)
SAND_YELLOW = (194, 178, 128)

# Set the height of colors
SKY_HEIGHT = 300
WATER_HEIGHT = 300 
SAND_HEIGHT = 100

def draw_background(screen):
    # Draw the sky
    screen.fill(SKY_BLUE)

    # Draw the water
    pygame.draw.rect(screen, OCEAN_BLUE, (0, SKY_HEIGHT, 1000, WATER_HEIGHT))

    # Draw the ocean floor
    pygame.draw.rect(screen, SAND_YELLOW, (0, SKY_HEIGHT + WATER_HEIGHT, 1000, SAND_HEIGHT))

def draw_boat_and_fisherman(screen):
    # Draw the boat
    pygame.draw.polygon(screen, (120, 70, 35), [
        (390, 280),
        (610, 280),
        (575, 320),
        (425, 320)
    ])

    # Draw the top edge of the boat
    pygame.draw.line(screen, (75, 45, 25), (390, 280), (610, 280), 5)

    # Draw the fisherman's head
    pygame.draw.circle(screen, (255, 205, 160), (500, 225), 15)

    # Draw the fisherman's body
    pygame.draw.rect(screen, (40, 100, 180), (488, 240, 24, 35))