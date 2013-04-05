
from constants import *

class Planet:
    def __init__(self, x, y, resources, rate):
        self.x = x
        self.y = y
        self.resources = resources
        self.rate = rate
        self.fungus = False
        self.station = False
        self.outpost = False
        self.collected = 0
        self.building = ""
        self.build_turns_left = 0
        self.probes = 0
        self.colony_ships = 0
        self.attack_ships = 0
        self.defense_ships = 0
        self.warp_gate = False

        self.visible = False
        self.seen = False
        self.last_seen_fungus = False

    def clear(self):
        self.station = False
        self.outpost = False
        self.collected = 0
        self.building = ""
        self.build_turns_left = 0
        self.probes = 0
        self.colony_ships = 0
        self.attack_ships = 0
        self.defense_ships = 0

    def add_fungus(self, strength=1):
        if strength > self.defense_ships:
            self.fungus = True
            if self.probes > 0:
                self.last_seen_fungus = True
            self.clear()
            return True
        return False

    def remove_fungus(self):
        self.fungus = False

    def add_station(self):
        self.station = True

    def remove_station(self):
        self.station = False

    def add_outpost(self):
        self.outpost = True

    def remove_outpost(self):
        self.outpost = False

    def add_probes(self, n):
        self.probes += n

    def remove_probes(self, n):
        if self.probes >= n:
            self.probes -= n

    def add_colony_ships(self, n):
        self.colony_ships += n

    def remove_colony_ships(self, n):
        if self.colony_ships >= n:
            self.colony_ships -= n

    def add_attack_ships(self, n):
        self.attack_ships += n

    def remove_attack_ships(self, n):
        if self.attack_ships >= n:
            self.attack_ships -= n

    def add_defense_ships(self, n):
        self.defense_ships += n

    def remove_defense_ships(self, n):
        if self.defense_ships >= n:
            self.defense_ships -= n

    def add_warp_gate(self):
        if not self.warp_gate and self.station:
            warp_gate = True

    def remove_warp_gate(self):
        warp_gate = False

    def make_probe(self):
        if self.station and self.collected >= PROBE_COST:
            self.collected -= PROBE_COST
            self.building = "Probe"
            self.build_turns_left = PROBE_TIME

    def make_colony_ship(self):
        if self.station and self.collected >= COLONYSHIP_COST:
            self.collected -= COLONYSHIP_COST
            self.building = "Colony Ship"
            self.build_turns_left = COLONYSHIP_TIME

    def make_station(self):
        if self.outpost and self.collected >= STATION_COST:
            self.collected -= STATION_COST
            self.building = "Station"
            self.build_turns_left = STATION_TIME

    def make_defense_ship(self):
        if self.station and self.collected >= DEFENSESHIP_COST:
            self.collected -= DEFENSESHIP_COST
            self.building = "Defense Ship"
            self.build_turns_left = DEFENSESHIP_TIME

    def make_attack_ship(self):
        if self.station and self.collected >= ATTACKSHIP_COST:
            self.collected -= ATTACKSHIP_COST
            self.building = "Attack Ship"
            self.build_turns_left = ATTACKSHIP_TIME

    def update(self, probe_neighbor):
        if self.station or self.outpost:
            if self.resources >= self.rate:
                self.collected += self.rate
                self.resources -= self.rate
            elif self.resources > 0:
                self.collected += self.resources
                self.resources -= self.resources
                
        if self.building != "":
            self.build_turns_left -= 1
            if self.build_turns_left == 0:
                if self.building == "Probe":
                    self.add_probes(1)
                elif self.building == "Colony Ship":
                    self.add_colony_ships(1)
                elif self.building == "Station":
                    self.remove_outpost()
                    self.add_station()
                elif self.building == "Defense Ship":
                    self.add_defense_ships(1)
                elif self.building == "Attack Ship":
                    self.add_attack_ships(1)
                self.building = ""

        self.visible = False
        if (self.station or self.outpost or self.probes > 0 or
            self.colony_ships > 0 or self.attack_ships > 0 or
            self.defense_ships > 0 or self.warp_gate):
            self.visible = True
            self.seen = True

        if probe_neighbor:
            self.visible = True
            self.seen = True
            if self.fungus:
                self.last_seen_fungus = True
