import pygame
import display
import fish
import shark
import scoreboard
import boat_movement
import hook

pygame.init()

# Initialize game window
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 700

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Fin It to Win It!")

# Initialize display settings
scoreboard.setup_scoreboard()
display.setup_images()
game_boat = boat_movement.Boat(screen)
game_hook = hook.Hook(screen, game_boat)

fish_list = [
    fish.Fish(screen, "GreyFish.png",       "small"),
    fish.Fish(screen, "GreyYellowFish.png", "small"),
    fish.Fish(screen, "YellowFish.png",     "medium"),
    fish.Fish(screen, "RedFish.png",        "medium"),
    fish.Fish(screen, "AngelFish.png",      "large"),
    fish.Fish(screen, "PurpleFish.png",     "large"),]

game_shark = shark.shark(screen)

clock = pygame.time.Clock() # Controls how fast the loop runs

# Game loop
running = True

while running:
    for event in pygame.event.get():
        # Handles quitting the game
        if event.type == pygame.QUIT:
            running = False
        # Handles spacebar press to lock the boat
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                if not game_boat.locked:
                    game_boat.locked = True

    # Check which keys are being pressed
    keys = pygame.key.get_pressed()

    # Update boat movement and hook position based on key presses
    game_boat.update(keys)
    game_hook.update(keys)

    for current_fish in fish_list:
        if not current_fish.caught:

            if game_hook.caught_fish is None:
                current_fish.update()

                if game_hook.hook_rectangle.colliderect(current_fish.rect):
                    game_hook.catch_fish(current_fish)

            else:
                if current_fish != game_hook.caught_fish:
                    current_fish.update()

    game_shark.update()

    # DRAW
    display.draw_background(screen)
    display.draw_fisherman(screen, game_boat.x, game_boat.direction)
    display.draw_treasure_chest(screen)
    scoreboard.draw_scoreboard(screen)

    # Ensures that the caught fish isn't drawn twice
    for current_fish in fish_list:
        if not current_fish.caught:
            if current_fish != game_hook.caught_fish:
                current_fish.draw(screen)

    game_shark.draw(screen)
    game_hook.draw(screen)

    # Update the display
    pygame.display.flip()
    clock.tick(60)  # Limit the frame rate to 60 FPS

# Close pygame
pygame.quit()

