import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { ClaimTerritoryDto } from './dto/claim-territory.dto';

@Injectable()
export class TerritoriesService {
  constructor(private prisma: PrismaService) {}

  async listAll() {
    return this.prisma.territory.findMany({
      orderBy: { score: 'desc' },
    });
  }

  async getByIndex(h3Index: string) {
    const territory = await this.prisma.territory.findUnique({ where: { h3Index } });
    if (!territory) {
      throw new NotFoundException('Territory not found');
    }
    return territory;
  }

  async claim(userId: string, dto: ClaimTerritoryDto) {
    const existing = await this.prisma.territory.findUnique({ where: { h3Index: dto.h3Index } });

    if (existing && existing.ownerId === userId) {
      return existing;
    }

    // Territory can be stolen from any other user — core game mechanic
    return this.prisma.territory.upsert({
      where: { h3Index: dto.h3Index },
      update: {
        ownerId: userId,
        score: (existing?.score ?? 0) + 1,
        lastActivity: new Date(),
      },
      create: {
        h3Index: dto.h3Index,
        ownerId: userId,
        score: 1,
        lastActivity: new Date(),
      },
    });
  }
}
