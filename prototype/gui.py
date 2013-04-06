
import pygame
from math import sqrt

from constants import *

class GUI:
    NONE, MOVE_PROBES, MOVE_COLONY, MOVE_DEFENSE, MOVE_ATTACK, PATH = range(6)
    def __init__(self, game):
        self.game = game
        self.graph = game.graph
        self.font = pygame.font.Font(None, 20)
        self.selected = None
        self.location = (100, 10)
        self.probes_move = 1
        self.colony_move = 1
        self.defense_move = 1
        self.attack_move = 1
        self.display = game.display
        self.state = self.NONE
        self.adjacent = []
        self.selection_path = []

    def reset_moves(self):
        self.probes_move = 1
        self.colony_move = 1
        self.defense_move = 1
        self.attack_move = 1

    def update_and_draw(self):
        mouse_pos = self.game.mouse_pos
        mouse_press = self.game.mouse_press
        for i in range(self.graph.size):
            this = self.graph.get_planet_by_number(i)
            if not this.visible: continue
            diffx = mouse_pos[0] - this.x
            diffy = mouse_pos[1] - this.y
            dist = sqrt(diffx * diffx + diffy * diffy)
            if dist < 10:
                pygame.draw.circle(self.display, PLANET_SELECT_COLOR,
                                   (this.x, this.y), PLANET_RADIUS*2, 1)
                if mouse_press:
                    self.game.mouse_press = False
                    if self.state == self.PATH:
                        if (this not in self.selected.resource_path and
                            this != self.selected):
                            if len(self.selection_path) > 0:
                                last = self.selection_path[-1]
                            else:
                                last = self.selected
                            if this in self.graph.get_neighbors_by_planet(last):
                                self.selected.sending = True
                                self.selection_path.append(this)
                                self.selected.resource_path.append(this)
                                self.selected.resources_on_path.append(0)
                                if this.station or this.outpost:
                                    self.state = self.NONE
                                    self.selection_path = []
                        elif len(self.selection_path) > 0 and this == self.selection_path[-1]:
                            self.selection_path.pop()
                            self.selected.resource_path.pop()
                            self.selected.resources_on_path.pop()
                    elif this == self.selected:
                        self.selected = None
                        self.state = self.NONE
                    elif self.state == self.MOVE_PROBES and this in self.adjacent:
                        p = self.probes_move
                        self.selected.remove_probes(p)
                        this.add_probes(p)
                        self.selected = None
                        self.state = self.NONE
                    elif self.state == self.MOVE_COLONY and this in self.adjacent:
                        c = self.colony_move
                        self.selected.remove_colony_ships(c)
                        this.add_colony_ships(c)
                        self.selected = None
                        self.state = self.NONE
                    elif self.state == self.MOVE_DEFENSE and this in self.adjacent:
                        c = self.defense_move
                        self.selected.remove_defense_ships(c)
                        this.add_defense_ships(c)
                        self.selected = None
                        self.state = self.NONE
                    elif self.state == self.MOVE_ATTACK and this in self.adjacent:
                        c = self.attack_move
                        self.selected.remove_attack_ships(c)
                        this.add_attack_ships(c)
                        self.selected = None
                        self.state = self.NONE
                    elif self.state == self.NONE:
                        self.selected = this
                        self.reset_moves()
            elif (self.state == self.MOVE_PROBES or
                  self.state == self.MOVE_COLONY or
                  self.state == self.MOVE_DEFENSE or
                  self.state == self.MOVE_ATTACK):
                if this in self.adjacent:
                    pygame.draw.circle(self.display, PLANET_OPTION_COLOR,
                                       (this.x, this.y), PLANET_RADIUS, 0)
            if this == self.selected:
                pygame.draw.circle(self.display, PLANET_SELECT_COLOR,
                                   (this.x, this.y), PLANET_RADIUS, 0)

        if self.selected:
            self.update_adjacent()

            if self.selected.probes > 0:
                f = self.font.render("Probes: ", True, TEXT_COLOR)
                self.display.blit(f, (self.location[0], self.location[1]))
                self.probe_buttons((self.location[0] +
                                       self.font.size("Probes: ")[0],
                                       self.location[1]))
            if self.selected.station:
                x = self.location[0] + 200
                y = self.location[1]
                f = self.font.render("Station: ", True, TEXT_COLOR)
                self.display.blit(f, (x, y))
                self.station_buttons((x + self.font.size("Station: ")[0], y))

            if self.selected.colony_ships > 0:
                x = self.location[0]
                y = self.location[1] + 40
                f = self.font.render("Colony Ships: ", True, TEXT_COLOR)
                self.display.blit(f, (x, y))
                self.colony_buttons((x + self.font.size("Colony Ships: ")[0], y))

            if self.selected.outpost:
                x = self.location[0] + 200
                y = self.location[1]
                f = self.font.render("Outpost: ", True, TEXT_COLOR)
                self.display.blit(f, (x, y))
                self.outpost_buttons((x + self.font.size("Outpost: ")[0], y))

            if self.selected.defense_ships > 0:
                x = self.location[0]
                y = self.location[1] + 80
                f = self.font.render("Defense Ships: ", True, TEXT_COLOR)
                self.display.blit(f, (x, y))
                self.defense_buttons((x + self.font.size("Defense Ships: ")[0], y))

            if self.selected.attack_ships > 0:
                x = self.location[0] + 250
                y = self.location[1] + 80
                f = self.font.render("Attack Ships: ", True, TEXT_COLOR)
                self.display.blit(f, (x, y))
                self.attack_buttons((x + self.font.size("Attack Ships: ")[0], y))

            if self.selected.station or self.selected.outpost:
                if len(self.selected.resource_path) > 0:
                    label = "Sending to %d" % self.graph.get_planet_number(self.selected.resource_path[-1])
                    f = self.font.render(label, True, TEXT_COLOR)
                    pos = (WIDTH - self.font.size(label)[0] - 20, self.location[1])
                    self.display.blit(f, (pos[0]+5, pos[1]+5))
                else:
                    label = "Send Resources"
                    pos = (WIDTH - self.font.size(label)[0] - 20, self.location[1])
                    if self.button(pos, label, 5):
                        self.state = self.PATH
                        pass

            if self.selected.station or self.selected.outpost and len(self.selected.resource_path) > 0:
                label = "Stop Sending"
                pos = (WIDTH - self.font.size(label)[0] - 20, self.location[1]+40)
                if self.button(pos, label, 5):
                    self.selected.sending = False
                    pass

            if self.selection_path:
                first = (self.selected.x, self.selected.y)
                p = self.selection_path
                for i in range(len(p)):
                    second = (p[i].x, p[i].y)
                    pygame.draw.line(self.display, PATH_COLOR, first, second, 3)
                    first = second

    def update_adjacent(self):
        self.adjacent = self.graph.get_neighbors_by_planet(self.selected)

    def button(self, pos, label, pad):
        s = self.font.size(label)
        pos = pygame.Rect(pos[0], pos[1], s[0]+pad*2, s[1]+pad*2)
        width = 1
        color = (0,0,0)
        pressed = False
        if pos.collidepoint(self.game.mouse_pos):
            width = 0
            color = (255,255,255)
            if self.game.mouse_press:
                self.game.mouse_press = False
                pressed = True
        
        pygame.draw.rect(self.display, (0,0,0), pos, width)
        f = self.font.render(label, True, color)
        self.display.blit(f, (pos.x+pad, pos.y+pad))
        return pressed

    def probe_buttons(self, pos):
        pad = 5
        if self.state == self.NONE and self.button(pos, "-", pad):
            any_press = True
            if self.probes_move > 1:
                self.probes_move -= 1
                
        label = "Move %d/%d" %(self.probes_move, self.selected.probes)
        x = pos[0] + pad*3 + self.font.size("-")[0]
        y = pos[1]
        if self.button((x, y), label, pad):
            if self.state != self.MOVE_PROBES:
                self.state = self.MOVE_PROBES
            else:
                self.state = self.NONE
            
            
        x += pad*3 + self.font.size(label)[0]
        if self.state == self.NONE and self.button((x, y), "+", pad):
            if self.probes_move < self.selected.probes:
                self.probes_move += 1

    def station_buttons(self, pos):
        if self.selected.building:
            f = self.font.render("%s done in %d turns"%(self.selected.building,
                                                        self.selected.build_turns_left),
                                 True, TEXT_COLOR)
            self.display.blit(f, pos)
        else:
            pad = 5
            label = "Probe: %d/%d"%(PROBE_COST, PROBE_TIME)
            if self.button(pos, label, pad):
                self.selected.make_probe()

            x = pos[0] + self.font.size(label)[0] + pad*3
            y = pos[1]
            label = "Colony Ship: %d/%d"%(COLONYSHIP_COST, COLONYSHIP_TIME)
            if self.button((x,y), label, pad):
                self.selected.make_colony_ship()

            x += self.font.size(label)[0] + pad*3
            y = pos[1]
            label = "Defense Ship: %d/%d"%(DEFENSESHIP_COST, DEFENSESHIP_TIME)
            if self.button((x,y), label, pad):
                self.selected.make_defense_ship()

            x += self.font.size(label)[0] + pad*3
            y = pos[1]
            label = "Attack Ship: %d/%d"%(ATTACKSHIP_COST, ATTACKSHIP_TIME)
            if self.button((x,y), label, pad):
                self.selected.make_attack_ship()

    def colony_buttons(self, pos):
        pad = 5
        if self.state == self.NONE and self.button(pos, "-", pad):
            any_press = True
            if self.colony_move > 1:
                self.colony_move -= 1
                
        label = "Move %d/%d" %(self.colony_move, self.selected.colony_ships)
        x = pos[0] + pad*3 + self.font.size("-")[0]
        y = pos[1]
        if self.button((x, y), label, pad):
            if self.state != self.MOVE_COLONY:
                self.state = self.MOVE_COLONY
            else:
                self.state = self.NONE
            
            
        x += pad*3 + self.font.size(label)[0]
        if self.state == self.NONE and self.button((x, y), "+", pad):
            if self.colony_move < self.selected.colony_ships:
                self.colony_move += 1

        if self.selected.probes > 0 and not self.selected.station:
            x += pad*3 + self.font.size("+")[0]
            if self.button((x, y), "Build Outpost", pad) and not self.selected.station:
                self.selected.remove_colony_ships(1)
                self.selected.remove_probes(1)
                self.selected.add_outpost()

    def outpost_buttons(self, pos):
        pad = 5
        if self.selected.building:
            f = self.font.render("%s done in %d turns"%(self.selected.building,
                                                    self.selected.build_turns_left),
                             True, TEXT_COLOR)
            self.display.blit(f, pos)
        else:
            if self.button(pos, "Upgrade to Station: %d/%d"%(STATION_COST,
                                                         STATION_TIME), pad):
                self.selected.make_station()

    def defense_buttons(self, pos):
        pad = 5
        if self.state == self.NONE and self.button(pos, "-", pad):
            any_press = True
            if self.defense_move > 1:
                self.defense_move -= 1
                
        label = "Move %d/%d" %(self.defense_move, self.selected.defense_ships)
        x = pos[0] + pad*3 + self.font.size("-")[0]
        y = pos[1]
        if self.button((x, y), label, pad):
            if self.state != self.MOVE_DEFENSE:
                self.state = self.MOVE_DEFENSE
            else:
                self.state = self.NONE
            
            
        x += pad*3 + self.font.size(label)[0]
        if self.state == self.NONE and self.button((x, y), "+", pad):
            if self.defense_move < self.selected.defense_ships:
                self.defense_move += 1

    def attack_buttons(self, pos):
        pad = 5
        if self.state == self.NONE and self.button(pos, "-", pad):
            any_press = True
            if self.attack_move > 1:
                self.attack_move -= 1
                
        label = "Move %d/%d" %(self.attack_move, self.selected.attack_ships)
        x = pos[0] + pad*3 + self.font.size("-")[0]
        y = pos[1]
        if self.button((x, y), label, pad):
            if self.state != self.MOVE_ATTACK:
                self.state = self.MOVE_ATTACK
            else:
                self.state = self.NONE
            
            
        x += pad*3 + self.font.size(label)[0]
        if self.state == self.NONE and self.button((x, y), "+", pad):
            if self.attack_move < self.selected.attack_ships:
                self.attack_move += 1
