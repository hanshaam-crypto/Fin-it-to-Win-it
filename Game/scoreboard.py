import pygame

# Scoreboard font
score_font = None

def setup_scoreboard():
    global score_font
    score_font = pygame.font.SysFont("trebuchetms", 36, bold=True)

def draw_scoreboard(screen, score):
    # Make a rectangle for the board
    board = pygame.Rect(0, 0, 190, 65)
    board.topright = (screen.get_width() - 20, 20)

    # Draw the oval and its outline
    pygame.draw.ellipse(screen, (220, 245, 255), board)
    pygame.draw.ellipse(screen, (60, 130, 170), board, 3)

    # Draw the score text
    score_text = score_font.render("Score: " + str(score), True, (35, 75, 100))
    score_rect = score_text.get_rect(center=board.center)
    screen.blit(score_text, score_rect)
