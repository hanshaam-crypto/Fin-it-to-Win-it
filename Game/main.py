import pygame
import display

pygame.init()

# Initializes the game window
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Fin It to Win It!")

# Game loop
running = True

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    display.draw_background(screen)
    display.draw_boat_and_fisherman(screen)

    # Update the display
    pygame.display.flip()

# Close pygame
pygame.quit()

