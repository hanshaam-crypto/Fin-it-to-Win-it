import pygame
import display
import fish

pygame.init()

# Initialize game window
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Fin It to Win It!")

# Initialize display settings
display.setup_fonts()
display.setup_images()


fishes = [
    fish.Fish(screen, "GreyFish.png",       "small"),
    fish.Fish(screen, "GreyYellowFish.png", "small"),
    fish.Fish(screen, "YellowFish.png",     "medium"),
    fish.Fish(screen, "RedFish.png",        "medium"),
    fish.Fish(screen, "AngelFish.png",      "large"),
    fish.Fish(screen, "PurpleFish.png",     "large"),]

clock = pygame.time.Clock() #Controls how fast the loop runs

# Game loop
running = True

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    for f in fishes:
        f.update()

    # # DRAW
    display.draw_background(screen)
    display.draw_fisherman(screen)
    display.draw_decorations(screen)
    display.draw_scoreboard(screen, 0)
    for f in fishes:
        f.draw(screen)
    

    # Update the display
    pygame.display.flip()
    clock.tick(60)  # Limit the frame rate to 60 FPS

# Close pygame
pygame.quit()

