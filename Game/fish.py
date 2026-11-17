import random
import pygame
import display

# For each size: (speed, points)
TIERS = {
    "small":  (3, 15),
    "medium": (4, 30),
    "large":  (6, 50),
}

class Fish:
    def __init__(self, screen, filename, tier):
        speed, points = TIERS[tier]

        # Sprites face right, so make a mirrored copy for swimming left
        self.image_right = display.load_image(filename)
        self.image_left = pygame.transform.flip(self.image_right, True, False)

        self.speed = speed
        self.points = points
        self.tier = tier
        self.respawning = False
        self.respawn_start = 0
        self.direction = random.choice([1, -1])    # 1 = swimming right, -1 = swimming left
        self.screen_width = screen.get_width()

        self.rect = self.image_right.get_rect()
        self.pick_depth(screen)
        self.rect.x = random.randint(0, self.screen_width - self.rect.width)

    def pick_depth(self, screen):
        # Choose a random height inside this fish's depth band
        band_top, band_bottom = display.get_band(screen, self.tier)

        # Keep small fish below the hook's starting spot
        if self.tier == "small":
            band_top = display.get_horizon(screen) + 40

        self.rect.top = random.randint(band_top, band_bottom - self.rect.height)

    def update(self):
        # Wait 2 seconds before swimming back in
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
        self.direction = random.choice([1, -1])
        self.pick_depth(screen)

        # Start just outside the screen
        if self.direction == 1:
            self.rect.left = -self.rect.width
        else:
            self.rect.left = self.screen_width

        self.respawning = True
        self.respawn_start = pygame.time.get_ticks()

    def draw(self, screen):
        # Don't draw during the 2-second wait
        if self.respawning:
            return

        if self.direction == 1:
            screen.blit(self.image_right, self.rect)
        else:
            screen.blit(self.image_left, self.rect)