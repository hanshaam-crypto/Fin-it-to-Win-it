import pygame
import display
import scoreboard

class Hook:
    def __init__(self, screen, boat):

        # Load hook image
        self.hook_image = display.load_image("Hook.png")

        # Set hook movement speed
        self.movement_speed = 5
        self.return_speed = 5

        # Store boat reference
        self.boat = boat
        self.screen = screen

        # Store caught fish
        self.caught_fish = None
        self.returning = False

        # Starting position of hook
        self.hook_rectangle = self.hook_image.get_rect()

        self.horizontal_offset = 60
        self.starting_y = display.get_horizon(screen) + 2

        self.hook_rectangle.centerx = boat.x + self.horizontal_offset
        self.hook_rectangle.top = self.starting_y


        # Remember the screen boundaries
        self.hook_top_limit = self.starting_y
        self.hook_bottom_limit = display.get_sand_top(screen)
    
    def update(self, keys):

        # Follow the boat horizontally only when not carrying a fish
        if self.caught_fish is None:
            if self.boat.direction == 1:
                self.hook_rectangle.centerx = self.boat.x + self.horizontal_offset
            else:
                self.hook_rectangle.centerx = self.boat.x - self.horizontal_offset

        # Automatically return when carrying a fish
        if self.returning:
            speed = getattr(self.caught_fish, "pull_speed", self.return_speed)
            self.hook_rectangle.y -= speed

            # Keep fish attached to the hook
            self.caught_fish.rect.centerx = self.hook_rectangle.centerx
            self.caught_fish.rect.bottom = self.hook_rectangle.bottom

            # Check if hook reached the boat
            if self.hook_rectangle.top <= self.hook_top_limit:
                self.hook_rectangle.top = self.hook_top_limit

                # Add points to the score
                scoreboard.add_points(self.caught_fish.points)

                self.caught_fish.respawn(self.screen)
                self.caught_fish = None
                self.returning = False

                # Unlock boat after delivering a fish
                self.boat.locked = False

        # Allow player to control hook only after locking the boat
        elif self.caught_fish is None and self.boat.locked:
            if keys[pygame.K_UP]:
                self.hook_rectangle.y -= self.movement_speed

            if keys[pygame.K_DOWN]:
                self.hook_rectangle.y += self.movement_speed

        # Keep hook within vertical boundaries
        if self.hook_rectangle.top < self.hook_top_limit:
            self.hook_rectangle.top = self.hook_top_limit

        if self.hook_rectangle.bottom > self.hook_bottom_limit:
            self.hook_rectangle.bottom = self.hook_bottom_limit


    def catch_fish(self, caught_fish):
        self.caught_fish = caught_fish
        self.returning = True

    def draw(self, screen):

        # Starting point of fishing line
        line_start = (
            self.hook_rectangle.centerx + 5,
            display.get_horizon(screen) + 2
        )

        # Ending point of fishing line
        line_end = (
            self.hook_rectangle.centerx + 5,
            self.hook_rectangle.top
        )

        # Draw fishing line
        pygame.draw.line(screen, (115, 115, 115), line_start, line_end, 2)

        # Draw caught fish
        if self.caught_fish is not None:
            self.caught_fish.draw(screen)

        # Draw hook
        screen.blit(self.hook_image, self.hook_rectangle)
