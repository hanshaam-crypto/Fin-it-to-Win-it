import random
import pygame
import display

# For each size: (height as a fraction of screen height, speed, points)
TIERS = {
    "small":  (0.05, 3, 15),
    "medium": (0.07, 4, 30),
    "large":  (0.09, 6, 50),
}

class Fish:
    def __init__(self, screen, filename, tier):
        height_fraction, speed, points = TIERS[tier]

        # Images: the originals all face right, so make a mirrored copy
        height = int(screen.get_height() * height_fraction)
        self.image_right = display.load_image(filename, height)
        self.image_left = pygame.transform.flip(self.image_right, True, False)

        self.speed = speed
        self.points = points
        self.direction = random.choice([1, -1])    # 1 = swimming right, -1 = swimming left
        self.screen_width = screen.get_width()

        # Start somewhere random, but inside this fish's depth band
        self.rect = self.image_right.get_rect()
        band_top, band_bottom = display.get_band(screen, tier)
        self.rect.top = random.randint(band_top, band_bottom - self.rect.height)
        self.rect.x = random.randint(0, self.screen_width - self.rect.width)

    def update(self):
        # Move
        self.rect.x += self.speed * self.direction

        # Turn around at the edges
        if self.rect.right >= self.screen_width:
            self.rect.right = self.screen_width
            self.direction = -1
        elif self.rect.left <= 0:
            self.rect.left = 0
            self.direction = 1

    def draw(self, screen):
        if self.direction == 1:
            screen.blit(self.image_right, self.rect)
        else:
            screen.blit(self.image_left, self.rect)