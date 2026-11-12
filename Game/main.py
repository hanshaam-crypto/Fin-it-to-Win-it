import pygame
import display
import fish

pygame.init()
display.setup_fonts()

# Initializes the game window
SCREEN_WIDTH = 1500
SCREEN_HEIGHT = 950

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Fin It to Win It!")

# Load the Images
boat_img = display.load_image("FishermanNoHook.png", int(SCREEN_HEIGHT * 0.15))
boat_rect = boat_img.get_rect(midbottom=(SCREEN_WIDTH // 2, display.get_horizon(screen) + 15))

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

    # DRAW
    display.draw_background(screen)
    screen.blit(boat_img, boat_rect)
    for f in fishes:
        f.draw(screen)
    display.draw_scoreboard(screen, 0) 

    # Update the display
    pygame.display.flip()
    clock.tick(60)  # Limit the frame rate to 60 FPS

# Close pygame
pygame.quit()

