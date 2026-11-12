
import random
import pygame
import display

class shark:
    def __init__(self, screen):

        # Set shark size and speed
        shark_height = int(screen.get_height() * 0.11)
        self.swimming_speed = 2
        self.point_value = -25

        # Load and resize shark image
        self.image_right = display.load_image("Shark.png", shark_height)
        self.image_left = pygame.transform.flip(self.image_right, True, False)

        # Randomize swimming direction
        self.swimming_direction = random.choice([1, -1])

        # Randomize swimming depth
        fish_size = random.choice(["medium", "large"])
        swimming_area_top, swimming_area_bottom = display.get_band(screen, fish_size)

        # Set starting position
        self.shark_rectangle = self.image_right.get_rect()
        self.shark_rectangle.top = random.randint(
            swimming_area_top,
            swimming_area_bottom - self.shark_rectangle.height
        )

        half_width = self.shark_rectangle.width // 2
        self.shark_rectangle.centerx = random.randint(
            half_width, screen.get_width() - half_width
        )

        self.game_screen_width = screen.get_width()

    def update(self):
        # Move shark
        self.shark_rectangle.x += self.swimming_speed * self.swimming_direction

        # If shark moves completely off the right side, bring it back on the left
        if self.shark_rectangle.left > self.game_screen_width:
            self.shark_rectangle.right = 0

        # If shark moves completely off the left side, bring it back on the right
        elif self.shark_rectangle.right < 0:
            self.shark_rectangle.left = self.game_screen_width

    def draw(self, screen):
        # Display shark facing its swimming direction
        if self.swimming_direction == 1:
            screen.blit(self.image_left, self.shark_rectangle)
        else:
            screen.blit(self.image_right, self.shark_rectangle)
