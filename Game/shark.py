
import random
import pygame
import display

class shark:
    def __init__(self, screen):
        self.swimming_speed = 2
        self.points = -25                      # negative: catching the shark costs points

        # The sprite faces right, so make a mirrored copy for swimming left
        self.image_right = display.load_image("Shark.png")
        self.image_left = pygame.transform.flip(self.image_right, True, False)

        self.swimming_direction = random.choice([1, -1])
        self.game_screen_width = screen.get_width()

        self.respawning = False
        self.respawn_start = 0

        self.rect = self.image_right.get_rect()
        self.pick_depth(screen)

        half_width = self.rect.width // 2
        self.rect.centerx = random.randint(half_width, screen.get_width() - half_width)

    def pick_depth(self, screen):
        # Swim in the middle or lower part of the ocean
        band_top, band_bottom = display.get_band(screen, random.choice(["medium", "large"]))
        self.rect.top = random.randint(band_top, band_bottom - self.rect.height)

    def update(self):
        # Wait 2 seconds after respawning before swimming
        if self.respawning:
            if pygame.time.get_ticks() - self.respawn_start < 2000:
                return
            else:
                self.respawning = False

        self.rect.x += self.swimming_speed * self.swimming_direction

        # Wrap around the screen
        if self.rect.left > self.game_screen_width:
            self.rect.right = 0
        elif self.rect.right < 0:
            self.rect.left = self.game_screen_width

    def respawn(self, screen):
        self.swimming_direction = random.choice([1, -1])
        self.pick_depth(screen)

        # Start just outside the screen
        if self.swimming_direction == 1:
            self.rect.right = 0
        else:
            self.rect.left = self.game_screen_width

        self.respawning = True
        self.respawn_start = pygame.time.get_ticks()

    def draw(self, screen):
        if self.respawning:
            return

        if self.swimming_direction == 1:
            screen.blit(self.image_right, self.rect)
        else:
            screen.blit(self.image_left, self.rect)