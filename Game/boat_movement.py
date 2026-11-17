import pygame
import display

class Boat:
    def __init__(self, screen):
        # Boat is initially unlocked
        self.locked = False

        # Set boat movement speed
        self.movement_speed = 5

        # Start boat in the middle of the screen
        self.x = screen.get_width() // 2

        # 1 = facing right, -1 = facing left
        self.direction = 1

        # Get the boat's width after resizing
        self.boat_width = display.fisherman_image.get_width()

        self.screen_width = screen.get_width()

    def update(self, keys):
        if not self.locked:
            if keys[pygame.K_LEFT]:
                self.x -= self.movement_speed
                self.direction = -1

            if keys[pygame.K_RIGHT]:
                self.x += self.movement_speed
                self.direction = 1

            # Keep boat inside the screen
            if self.x < 0:
                self.x = 0

            if self.x > self.screen_width - self.boat_width:
                self.x = self.screen_width - self.boat_width