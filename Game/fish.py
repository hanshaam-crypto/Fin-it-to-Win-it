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
        self.tier = tier
        self.caught = False
        self.respawning = False
        self.respawn_start = 0
        self.direction = random.choice([1, -1])    # 1 = swimming right, -1 = swimming left
        self.screen_width = screen.get_width()

        # Start somewhere random, but inside this fish's depth band
        self.rect = self.image_right.get_rect()
        band_top, band_bottom = display.get_band(screen, tier)

        # Start small fish below the hook
        if tier == "small":
            band_top = display.get_horizon(screen) + 40

        self.rect.top = random.randint(band_top, band_bottom - self.rect.height)

        self.rect.x = random.randint(0, self.screen_width - self.rect.width)

    def update(self):
        # Wait 2 seconds before swimming onto the screen
        if self.respawning:
            if pygame.time.get_ticks() - self.respawn_start < 2000:
                return
            else:
                self.respawning = False

        # Move
        self.rect.x += self.speed * self.direction

        # Turn around at the edges
        if self.rect.right >= self.screen_width:
            self.rect.right = self.screen_width
            self.direction = -1
        elif self.rect.left <= 0:
            self.rect.left = 0
            self.direction = 1

    def respawn(self, screen):
        # Choose a new direction
        self.direction = random.choice([1, -1])

        # Choose a new vertical position in the same depth tier
        band_top, band_bottom = display.get_band(screen, self.tier)

        # Keep small fish below the hook
        if self.tier == "small":
            band_top = display.get_horizon(screen) + 40

        self.rect.top = random.randint(band_top, band_bottom - self.rect.height)

        # Start just outside the screen
        if self.direction == 1:
            self.rect.left = -self.rect.width
        else:
            self.rect.left = self.screen_width

        # Reset caught and respawning flags
        self.caught = False
        self.respawning = True
        self.respawn_start = pygame.time.get_ticks()

    def draw(self, screen):
        # Don't draw fish during the 2-second delay
        if self.respawning:
            return

        if self.direction == 1:
            screen.blit(self.image_right, self.rect)
        else:
            screen.blit(self.image_left, self.rect)