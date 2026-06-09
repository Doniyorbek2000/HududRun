import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
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

    if (existing && existing.ownerId) {
      throw new ConflictException('Territory already claimed');
    }

    return this.prisma.territory.upsert({
      where: { h3Index: dto.h3Index },
      update: {
        ownerId: userId,
        lastActivity: new Date(),
      },
      create: {
        h3Index: dto.h3Index,
        ownerId: userId,
        lastActivity: new Date(),
      },
    });
  }
}
