import pygame

# Each letter is one pixel. "." means transparent.
FISH = [
    "......oooo......",
    "..o.oobbbboo....",
    ".ooobbbbbbbboo..",
    "oobbbbbbbbbbebbo",
    "oobbbbbbbbbbbbbo",
    ".ooobbbbbbbboo..",
    "..o.oobbbboo....",
    "......oooo......",
]

HOOK = [
    "..gg",
    "..gg",
    "..gg",
    "..gg",
    "g.gg",
    "gggg",
    ".ggg",
]

# A palette says what color each letter is
HOOK_PAL  = {".": None, "g": (70, 70, 70)}

BOAT = [
    "....r...........................",
    ".....r..........................",
    "......r.........................",
    ".......rr..........hhhhhhhh.....",
    ".........r........hhhhhhhhhh....",
    "...........r........sssses......",
    "............r.......ssssss......",
    ".............rr.....vvvvvvv.....",
    "...............r.ssssvvvvvv.....",
    "................rssssvvvvvv.....",
    ".................r..vvvvvvv.....",
    "................ppppppppppp.....",
    "................ppppppppppp.....",
    "..dddddddddddddddddddddddddddd..",
    "...wwwwwwwwwwwwwwwwwwwwwwwwww...",
    "....wwwwwwwwwwwwwwwwwwwwwwww....",
    ".....wwwwwwwwwwwwwwwwwwwwww.....",
    "......wwwwwwwwwwwwwwwwwwww......",
    "........wwwwwwwwwwwwwwww........",
]

SHARK = [
    "...............g................",
    "gg............gg................",
    "gggg.........ggggg..............",
    "gggggg.....gggggggggggggg.......",
    ".......gggggggggggggggggggggg...",
    ".....gggggggggggggggggggggegggg.",
    ".....gggggggggggggggggggggggggg.",
    ".....gggggggggggggggggggggggggg.",
    "ggggggwwwwwwwwwwwwwwwwwwmmmmwww.",
    "gggg...wwwwwwwwwwwwwwwwwwwwww...",
    "gg.........wwwwwwwwwwwwww.......",
    "................................",
]

CHEST = [
    "..dddddddddddd..",
    ".dwwywwwwwwywwd.",
    ".dwwywwwwwwywwd.",
    ".dwwywwwwwwywwd.",
    ".dddyddyyddyddd.",
    ".dwwywwyywwywwd.",
    ".dwwywwyywwywwd.",
    ".dwwywwwwwwywwd.",
    ".dwwywwwwwwywwd.",
    ".dwwywwwwwwywwd.",
    ".dwwywwwwwwywwd.",
    ".dddddddddddddd.",
]

BOAT_PAL = {".": None, "r": (60, 60, 70), "h": (70, 130, 60), "s": (250, 205, 160),
            "e": (0, 0, 0), "v": (240, 150, 60), "p": (90, 100, 120),
            "d": (80, 50, 30), "w": (130, 85, 50)}

SHARK_PAL = {".": None, "g": (110, 120, 135), "w": (225, 230, 240),
             "e": (0, 0, 0), "m": (40, 40, 50)}

CHEST_PAL = {".": None, "d": (80, 50, 30), "w": (130, 85, 50), "y": (240, 200, 60)}

def make_sprite(rows, palette, scale):
    height = len(rows)
    width = len(rows[0])
    surface = pygame.Surface((width, height), pygame.SRCALPHA)

    for y, row in enumerate(rows):
        for x, letter in enumerate(row):
            color = palette[letter]
            if color is not None:
                surface.set_at((x, y), color)

    return pygame.transform.scale(surface, (width * scale, height * scale))

def fish_palette(outline, body):
    return {".": None, "o": outline, "b": body, "e": (0, 0, 0)}

# The old picture file names are now just labels that pick a sprite
SPRITES = {
    "GreyFish.png":       (FISH,  fish_palette((30, 30, 60),  (140, 150, 170))),
    "GreyYellowFish.png": (FISH,  fish_palette((70, 70, 30),  (200, 195, 120))),
    "YellowFish.png":     (FISH,  fish_palette((120, 90, 0),  (250, 220, 60))),
    "RedFish.png":        (FISH,  fish_palette((80, 10, 10),  (230, 70, 60))),
    "AngelFish.png":      (FISH,  fish_palette((120, 60, 0),  (240, 150, 60))),
    "PurpleFish.png":     (FISH,  fish_palette((50, 20, 70),  (130, 70, 160))),
    "Shark.png":          (SHARK, SHARK_PAL),
    "TreasureChest.png":  (CHEST, CHEST_PAL),
    "Hook.png":           (HOOK,  HOOK_PAL),
}

# How much each sprite is enlarged (whole numbers only: 1 pixel in the grid = N screen pixels).
# Change a number here to change that sprite's size everywhere.
SCALES = {
    "GreyFish.png": 3,  "GreyYellowFish.png": 3,    # small:  48 x 24
    "YellowFish.png": 4, "RedFish.png": 4,          # medium: 64 x 32
    "AngelFish.png": 5,  "PurpleFish.png": 5,       # large:  80 x 40
    "Shark.png": 4,                                 # 128 x 48
    "TreasureChest.png": 4,                         # 64 x 48
    "Hook.png": 5,                                  # 20 x 35
}

def get_sprite(name):
    rows, palette = SPRITES[name]
    return make_sprite(rows, palette, SCALES[name])
