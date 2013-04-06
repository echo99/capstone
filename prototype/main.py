
import pygame
from pygame.locals import *
from constants import *
from graph import Graph
from gui import GUI
from math import cos, sin
from random import random, choice

class Game:
    def __init__(self):
        self.display = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("Prototype")

        self.font = pygame.font.Font(None, 20)
        self.clock = pygame.time.Clock()

        self.graph = Graph()
        self.gui = GUI(self)

        self.turn = -1
        self.mouse_pos = (0,0)
        self.mouse_press = False

        self.running = True

        p = self.graph.get_planet_by_number(PLAYER_START)
        p.add_station()
        p.add_probes(1)

        self.update()

        self.show_all = False

    def get_input(self):
        for event in pygame.event.get():
            if event.type == QUIT:
                self.running = False
            elif event.type == KEYDOWN:
                if event.key == K_ESCAPE:
                    self.running = False
                elif event.key == K_s:
                    self.show_all = True
                elif event.key == K_SPACE:
                    self.update()
            elif event.type == KEYUP:
                if event.key == K_s:
                    self.show_all = False
            elif event.type == MOUSEBUTTONDOWN:
                if event.button == 1:
                    self.mouse_press = True
            elif event.type == MOUSEBUTTONUP:
                if event.button == 1:
                    self.mouse_press = False
        self.mouse_pos = pygame.mouse.get_pos()

    def neighbor_has_probe(self, i):
        neighbors = self.graph.get_neighbors_by_number(i)
        for n in neighbors:
            if n.probes > 0:
                return True

    def advance_fungus(self, i):
        neighbors = self.graph.get_neighbors_by_number(i)
        free_neighbors = []
        owned_neighbors = []
        for n in neighbors:
            if not n.fungus:
                free_neighbors.append(n)
            else:
                owned_neighbors.append(n)
        if len(free_neighbors) > 0 and random() <= FUNGUS_SPREAD_CHANCE:
            take = choice(free_neighbors)
            if (take.add_fungus(len(owned_neighbors)+1) and
                self.neighbor_has_probe(self.graph.get_planet_number(take))):
                take.last_seen_fungus = True

    def update(self):
        self.turn += 1
        for i in range(self.graph.size):
            this = self.graph.get_planet_by_number(i)
            if this.fungus:
                self.advance_fungus(i)
            this.update(self.neighbor_has_probe(i))
        # destroy things on fungus-owned planets or take with attack ships
        for i in range(self.graph.size):
            neighbors = self.graph.get_neighbors_by_number(i)
            owned_neighbors = []
            for n in neighbors:
                if n.fungus:
                    owned_neighbors.append(n)
            this = self.graph.get_planet_by_number(i)
            if this.fungus:
                if this.attack_ships > len(owned_neighbors)+1:
                    this.remove_fungus()
                    this.last_seen_fungus = False
                else:
                    this.clear()

    def draw(self):
        self.display.fill((255,255,255))
        self.draw_graph()
        self.draw_turn_button()
        self.gui.update_and_draw();
        pygame.display.flip()

    def draw_graph(self):
        for i in range(self.graph.size):
            this = self.graph.get_planet_by_number(i)
            neighbors = self.graph.get_neighbors_by_number(i)
            for n in neighbors:
                if self.graph.get_planet_number(n) < i:
                    if self.show_all or this.seen and n.seen:
                        pygame.draw.line(self.display, VISIBLE_LINE_COLOR,
                                         (this.x, this.y), (n.x, n.y))
            self.draw_planet(this)
            
##            x = this.x + 15
##            y1 = this.y - 10
##            y2 = this.y + 10
##            t = self.font.render("rsrc: %d" %(this.resources), True, TEXT_COLOR)
##            self.display.blit(t, (x, y1))
##            t = self.font.render("rate: %d" %(this.rate), True, TEXT_COLOR)
##            self.display.blit(t, (x, y2))

    def draw_planet(self, planet):
        if not self.show_all and not planet.visible and not planet.seen: return
        if planet.visible:
            if planet.fungus:
                color = VISIBLE_FUNGUS_PLANET_COLOR
            else:
                color = VISIBLE_PLANET_COLOR
        else:
            if planet.last_seen_fungus:
                color = SEEN_FUNGUS_PLANET_COLOR
            elif self.show_all and planet.fungus:
                color = VISIBLE_FUNGUS_PLANET_COLOR
            else:
                color = SEEN_PLANET_COLOR
            
        pygame.draw.circle(self.display, color,(planet.x, planet.y), PLANET_RADIUS)

        t = pygame.time.get_ticks()
        if planet.station:
            x = cos(t/1000.0) * 20 + planet.x
            y = sin(t/1000.0) * 20 + planet.y
            f = self.font.render("S:%d" %(planet.collected), True, STATION_COLOR)
            s = self.font.size("S")
            self.display.blit(f, (int(x-s[0]/2.0), int(y-s[1]/2.0)))
        if planet.probes > 0:
            f = self.font.render("P:%d" %(planet.probes), True, PROBE_COLOR)
            s = self.font.size("P")
            x = int(cos(t/1000.0+100) * 30 + planet.x - s[0] / 2.0)
            y = int(sin(t/1000.0+100) * 30 + planet.y - s[1] / 2.0)
            self.display.blit(f, (x, y))
            f = self.font.render("res: %d" %(planet.resources), True, PROBE_COLOR)
            self.display.blit(f, (x, y+s[1]))
            f = self.font.render("rate: %d" %(planet.rate), True, PROBE_COLOR)
            self.display.blit(f, (x, y+s[1]*2))
        if planet.colony_ships > 0:
            x = cos(t/1000.0+200) * 30 + planet.x
            y = sin(t/1000.0+200) * 30 + planet.y
            f = self.font.render("C:%d" %(planet.colony_ships), True, COLONYSHIP_COLOR)
            s = self.font.size("C")
            self.display.blit(f, (int(x-s[0]/2.0), int(y-s[1]/2.0)))
        if planet.outpost:
            x = cos(t/1000.0+300) * 20 + planet.x
            y = sin(t/1000.0+300) * 20 + planet.y
            f = self.font.render("O:%d" %(planet.collected), True, OUTPOST_COLOR)
            s = self.font.size("O")
            self.display.blit(f, (int(x-s[0]/2.0), int(y-s[1]/2.0)))
        if planet.defense_ships > 0:
            x = cos(t/1000.0+500) * 40 + planet.x
            y = sin(t/1000.0+500) * 40 + planet.y
            f = self.font.render("D:%d" %(planet.defense_ships), True, DEFENSE_COLOR)
            s = self.font.size("D")
            self.display.blit(f, (int(x-s[0]/2.0), int(y-s[1]/2.0)))
        if planet.attack_ships > 0:
            x = cos(t/1000.0+600) * 40 + planet.x
            y = sin(t/1000.0+600) * 40 + planet.y
            f = self.font.render("A:%d" %(planet.attack_ships), True, ATTACK_COLOR)
            s = self.font.size("A")
            self.display.blit(f, (int(x-s[0]/2.0), int(y-s[1]/2.0))) 

    def draw_turn_button(self):
        pad = 10
        label = "Turn: %d" %(self.turn)
        s = self.font.size(label)
        pos = Rect(10, 10, s[0]+pad*2, s[1]+pad*2)
        width = 2
        color = (0,0,0)
        if pos.collidepoint(self.mouse_pos):
            width = 0
            color = (255,255,255)
            if self.mouse_press:
                self.update()
                self.mouse_press = False
        
        pygame.draw.rect(self.display, (0,0,0), pos, width)
        f = self.font.render(label, True, color)
        self.display.blit(f, (pos.x+pad, pos.y+pad))

    def run(self):
        while self.running:
            self.clock.tick(30)
            self.get_input()
            self.draw()

if __name__ == "__main__":
    pygame.init()
    game = Game()
    game.run()
    pygame.quit()
