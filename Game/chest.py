import random
import pygame
import display

class Chest:
    def __init__(self, screen):
        self.screen = screen
        self.points = 100
        self.pull_speed = 2        # heavy: fish are pulled up at 5, the chest at 2

        self.image = display.load_image("TreasureChest.png")
        self.rect = self.image.get_rect()

        self.respawning = False
        self.respawn_start = 0

        self.place()

    def place(self):
        # Random spot along the sand
        half_width = self.rect.width // 2
        self.rect.centerx = random.randint(half_width, self.screen.get_width() - half_width)
        self.rect.bottom = display.get_sand_top(self.screen) + 15

    def update(self):
        # After the 2-second wait, put the chest back on the sand
        if self.respawning:
            if pygame.time.get_ticks() - self.respawn_start >= 2000:
                self.respawning = False
                self.place()

    def respawn(self, screen):
        # Hide it below the screen so it can't be hit while waiting
        self.rect.top = screen.get_height() + 10
        self.respawning = True
        self.respawn_start = pygame.time.get_ticks()

    def draw(self, screen):
        if self.respawning:
            return
        screen.blit(self.image, self.rect)