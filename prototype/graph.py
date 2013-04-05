
from random import randint, random

from planet import Planet
from constants import *

class Graph:
    def __init__(self):
        self.planets = []
        self.graph = [None] * 36
        self._init_graph()
        self.size = 36

    def get_planet_by_number(self, num):
        return self.planets[num]

    def get_planet_number(self, planet):
        return self.planets.index(planet)

    def get_neighbors_by_number(self, num):
        return self.graph[num]

    def get_neighbors_by_planet(self, planet):
        return self.graph[self.get_planet_number(planet)]

    def _init_graph(self):
        m = 20
        self.planets = [
            Planet(37*m, 3*m, self._get_resources(), self._get_rate()),
            Planet(20*m, 4*m, self._get_resources(), self._get_rate()),
            Planet(4*m, 5*m, self._get_resources(), self._get_rate()),
            Planet(29*m, 5*m, self._get_resources(), self._get_rate()),
            Planet(43*m, 6*m, self._get_resources(), self._get_rate()),
            Planet(49*m, 7*m, self._get_resources(), self._get_rate()),
            Planet(11*m, 8*m, self._get_resources(), self._get_rate()),
            Planet(35*m, 8*m, self._get_resources(), self._get_rate()),
            Planet(26*m, 10*m, self._get_resources(), self._get_rate()),
            Planet(15*m, 13*m, self._get_resources(), self._get_rate()),
            Planet(38*m, 13*m, self._get_resources(), self._get_rate()),
            Planet(4*m, 15*m, self._get_resources(), self._get_rate()),
            Planet(21*m, 16*m, self._get_resources(), self._get_rate()),
            Planet(45*m, 16*m, self._get_resources(), self._get_rate()),
            Planet(33*m, 17*m, self._get_resources(), self._get_rate()),
            Planet(10*m, 19*m, self._get_resources(), self._get_rate()),
            Planet(20*m, 21*m, self._get_resources(), self._get_rate()),
            Planet(29*m, 22*m, self._get_resources(), self._get_rate()),
            Planet(45*m, 22*m, self._get_resources(), self._get_rate()),
            Planet(3*m, 23*m, self._get_resources(), self._get_rate()),
            Planet(37*m, 25*m, self._get_resources(), self._get_rate()),
            Planet(51*m, 25*m, self._get_resources(), self._get_rate()),
            Planet(24*m, 26*m, self._get_resources(), self._get_rate()),
            Planet(9*m, 27*m, self._get_resources(), self._get_rate()),
            Planet(15*m, 27*m, self._get_resources(), self._get_rate()),
            Planet(20*m, 31*m, self._get_resources(), self._get_rate()),
            Planet(31*m, 31*m, self._get_resources(), self._get_rate()),
            Planet(45*m, 32*m, self._get_resources(), self._get_rate()),
            Planet(7*m, 34*m, self._get_resources(), self._get_rate()),
            Planet(37*m, 34*m, self._get_resources(), self._get_rate()),
            Planet(14*m, 35*m, self._get_resources(), self._get_rate()),
            Planet(22*m, 37*m, self._get_resources(), self._get_rate()),
            Planet(29*m, 37*m, self._get_resources(), self._get_rate()),
            Planet(47*m, 38*m, self._get_resources(), self._get_rate()),
            Planet(7*m, 40*m, self._get_resources(), self._get_rate()),
            Planet(37*m, 40*m, self._get_resources(), self._get_rate())
        ]

        p = self.planets[PLAYER_START]
        p.resources = 100
        p.rate = 2

        f = self.planets[FUNGUS_START]
        f.add_fungus()

        self.graph[0] = [self.planets[3], self.planets[4], self.planets[7]]
        self.graph[1] = [self.planets[3], self.planets[6], self.planets[8]]
        self.graph[2] = [self.planets[6]]
        self.graph[3] = [self.planets[0], self.planets[1], self.planets[7], self.planets[8]]
        self.graph[4] = [self.planets[0], self.planets[5], self.planets[7], self.planets[10]]
        self.graph[5] = [self.planets[4], self.planets[13]]
        self.graph[6] = [self.planets[1], self.planets[2], self.planets[9], self.planets[11]]
        self.graph[7] = [self.planets[0], self.planets[3], self.planets[4], self.planets[8], self.planets[10], self.planets[14]]
        self.graph[8] = [self.planets[1], self.planets[3], self.planets[7], self.planets[12], self.planets[14]]
        self.graph[9] = [self.planets[6], self.planets[12], self.planets[15], self.planets[16]]
        self.graph[10] = [self.planets[4], self.planets[7], self.planets[13], self.planets[14]]
        self.graph[11] = [self.planets[6], self.planets[15], self.planets[19]]
        self.graph[12] = [self.planets[8], self.planets[9], self.planets[16], self.planets[17]]
        self.graph[13] = [self.planets[5], self.planets[10], self.planets[18]]
        self.graph[14] = [self.planets[7], self.planets[8], self.planets[10], self.planets[17], self.planets[20]]
        self.graph[15] = [self.planets[9], self.planets[11], self.planets[19], self.planets[23], self.planets[24]]
        self.graph[16] = [self.planets[9], self.planets[12], self.planets[17], self.planets[22], self.planets[24]]
        self.graph[17] = [self.planets[12], self.planets[14], self.planets[16], self.planets[20], self.planets[22], self.planets[26]]
        self.graph[18] = [self.planets[13], self.planets[20], self.planets[21], self.planets[27]]
        self.graph[19] = [self.planets[11], self.planets[15], self.planets[23]]
        self.graph[20] = [self.planets[14], self.planets[17], self.planets[18], self.planets[26], self.planets[27], self.planets[29]]
        self.graph[21] = [self.planets[18], self.planets[27]]
        self.graph[22] = [self.planets[16], self.planets[17], self.planets[24], self.planets[25], self.planets[26]]
        self.graph[23] = [self.planets[15], self.planets[19], self.planets[24], self.planets[28], self.planets[30]]
        self.graph[24] = [self.planets[15], self.planets[16], self.planets[22], self.planets[23], self.planets[25], self.planets[30]]
        self.graph[25] = [self.planets[22], self.planets[24], self.planets[30], self.planets[31]]
        self.graph[26] = [self.planets[17], self.planets[20], self.planets[22], self.planets[29], self.planets[32]]
        self.graph[27] = [self.planets[18], self.planets[21], self.planets[29], self.planets[33]]
        self.graph[28] = [self.planets[23], self.planets[30], self.planets[34]]
        self.graph[29] = [self.planets[20], self.planets[26], self.planets[27], self.planets[32], self.planets[35]]
        self.graph[30] = [self.planets[23], self.planets[24], self.planets[25], self.planets[28], self.planets[31], self.planets[34]]
        self.graph[31] = [self.planets[25], self.planets[30], self.planets[32]]
        self.graph[32] = [self.planets[26], self.planets[29], self.planets[31], self.planets[35]]
        self.graph[33] = [self.planets[27]]
        self.graph[34] = [self.planets[28], self.planets[30]]
        self.graph[35] = [self.planets[29], self.planets[32]]
        
    def _get_resources(self):
        return randint(RESOURCE_LOW, RESOURCE_HIGH)

    def _get_rate(self):
        r = random()
        if r <= RATE_1_CHANCE:
            return 1
        if r <= RATE_1_CHANCE + RATE_2_CHANCE:
            return 2
        if r <= RATE_1_CHANCE + RATE_2_CHANCE + RATE_3_CHANCE:
            return 3
