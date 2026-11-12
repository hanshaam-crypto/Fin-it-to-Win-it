import pygame
import display

class Hook:
    def __init__(self, screen, boat):

        # Load hook image
        self.hook_image = display.load_image("Hook.png", 35)

        # Set hook movement speed
        self.movement_speed = 5

        # Store boat reference
        self.boat = boat

        # Starting position of hook
        self.hook_rectangle = self.hook_image.get_rect()

        # Adjust these values to position the hook
        self.horizontal_offset = 53
        self.starting_y = display.get_horizon(screen) + 2

        self.hook_rectangle.centerx = boat.x + self.horizontal_offset
        self.hook_rectangle.top = self.starting_y

        # Remember the screen boundaries
        self.screen_height = screen.get_height()
        self.hook_top_limit = self.starting_y
        self.hook_bottom_limit = display.get_sand_top(screen) - self.hook_rectangle.height

    def update(self, keys):

        # Follow the boat horizontally
        if self.boat.direction == 1:
            self.hook_rectangle.centerx = self.boat.x + self.horizontal_offset
        else:
            self.hook_rectangle.centerx = self.boat.x - self.horizontal_offset

        # Move hook down
        if keys[pygame.K_DOWN]:
            self.hook_rectangle.y += self.movement_speed

        # Move hook up
        if keys[pygame.K_UP]:
            self.hook_rectangle.y -= self.movement_speed

        # Keep hook within vertical boundaries
        if self.hook_rectangle.top < self.hook_top_limit:
            self.hook_rectangle.top = self.hook_top_limit

        if self.hook_rectangle.bottom > self.hook_bottom_limit:
            self.hook_rectangle.bottom = self.hook_bottom_limit

    def draw(self, screen):

        # Starting point of fishing line
        line_start = (
            self.hook_rectangle.centerx - 4,
            display.get_horizon(screen) + 2
        )

        # Ending point of fishing line
        line_end = (
            self.hook_rectangle.centerx - 4,
            self.hook_rectangle.top
        )

        # Draw fishing line
        pygame.draw.line(screen, (115, 115, 115), line_start, line_end, 2)

        # Draw hook
        screen.blit(self.hook_image, self.hook_rectangle)