import pygame
import display
import fish
import shark
import chest
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
    fish.Fish(screen, "PurpleFish.png",     "large"),
]

game_shark = shark.shark(screen)
game_chest = chest.Chest(screen)

clock = pygame.time.Clock()

# Game loop
running = True

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        # Spacebar locks the boat so the hook can be lowered
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                if not game_boat.locked:
                    game_boat.locked = True

    keys = pygame.key.get_pressed()

    # UPDATE
    game_boat.update(keys)
    game_hook.update(keys)

    # Update fish and check for collisions with the hook
    for current_fish in fish_list:
        if game_hook.caught_fish is None:
            current_fish.update()

            if game_hook.hook_rectangle.colliderect(current_fish.rect):
                game_hook.catch_fish(current_fish)
        elif current_fish != game_hook.caught_fish:
            current_fish.update()

    # Update shark and check for collisions with the hook
    if game_hook.caught_fish is None:
        game_shark.update()

        if game_hook.hook_rectangle.colliderect(game_shark.rect):
            game_hook.catch_fish(game_shark)
    elif game_hook.caught_fish != game_shark:
        game_shark.update()

    game_chest.update()

    # Check for collision between hook and chest
    if game_hook.caught_fish is None:
        if game_hook.hook_rectangle.colliderect(game_chest.rect):
            game_hook.catch_fish(game_chest)

    # DRAW
    display.draw_background(screen)
    display.draw_fisherman(screen, game_boat.x, game_boat.direction)

    # Draw the chest, fish, and shark only if they are not currently caught by the hook
    if game_chest != game_hook.caught_fish:
        game_chest.draw(screen)

    # Draw each fish only if it is not currently caught by the hook
    for current_fish in fish_list:
        if current_fish != game_hook.caught_fish:
            current_fish.draw(screen)

    # Draw the shark only if it is not currently caught by the hook
    if game_shark != game_hook.caught_fish:
        game_shark.draw(screen)

    scoreboard.draw_scoreboard(screen)
    game_hook.draw(screen)

    pygame.display.flip()
    clock.tick(60)

pygame.quit()
