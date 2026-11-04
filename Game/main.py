import pygame

pygame.init()

# Initializes the game window
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Fin It to Win It!")

# Background Color
BLUE = (30, 144, 255) #RGB

# Game loop
running = True

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # Draw Background
    screen.fill(BLUE)

    # Update the display
    pygame.display.flip()

# Close pygame
pygame.quit()

