import pygame
import display

class Boat:
    def __init__(self, screen):

        # Set boat movement speed
        self.movement_speed = 5

        # Start boat in the middle of the screen
        self.x = screen.get_width() // 2

        # 1 = facing right, -1 = facing left
        self.direction = 1

        # Get the boat's width after resizing
        image_width, image_height = display.fisherman_image.get_size()
        boat_height = int(screen.get_height() * 0.15)
        self.boat_width = int(image_width * boat_height / image_height)

        self.screen_width = screen.get_width()

    def update(self, keys):

        # Move left
        if keys[pygame.K_LEFT]:
            self.x -= self.movement_speed
            self.direction = -1

        # Move right
        elif keys[pygame.K_RIGHT]:
            self.x += self.movement_speed
            self.direction = 1

        # Keep the boat inside the screen
        half_width = self.boat_width // 2

        if self.x < half_width:
            self.x = half_width

        elif self.x > self.screen_width - half_width:
            self.x = self.screen_width - half_width