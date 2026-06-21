import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { ClaimTerritoryDto } from './dto/claim-territory.dto';

@Injectable()
export class TerritoriesService {
  constructor(private prisma: PrismaService) {}

  async listAll() {
    const territories = await this.prisma.territory.findMany({
      orderBy: { score: 'desc' },
      include: {
        owner: {
          select: { id: true, username: true, color: true },
        },
      },
    });
    return territories.map((t) => ({
      id: t.id,
      h3Index: t.h3Index,
      ownerId: t.ownerId,
      ownerUsername: t.owner?.username ?? null,
      ownerColor: t.owner?.color ?? '#ADC6FF',
      score: t.score,
      area: t.area,
      polygon: t.polygon,
      lastActivity: t.lastActivity,
      shieldedUntil: t.shieldedUntil,
    }));
  }

  async getByIndex(h3Index: string) {
    const territory = await this.prisma.territory.findUnique({
      where: { h3Index },
      include: { owner: { select: { id: true, username: true, color: true } } },
    });
    if (!territory) throw new NotFoundException('Territory not found');
    return territory;
  }

  async claim(userId: string, dto: ClaimTerritoryDto) {
    const existing = await this.prisma.territory.findUnique({ where: { h3Index: dto.h3Index } });
    if (existing && existing.ownerId === userId) return existing;

    if (existing && existing.ownerId !== userId && existing.shieldedUntil && existing.shieldedUntil > new Date()) {
      throw new ForbiddenException('This territory is shielded!');
    }

    const previousOwner = existing?.ownerId ?? null;

    return this.prisma.$transaction(async (tx) => {
      const territory = await tx.territory.upsert({
        where: { h3Index: dto.h3Index },
        update: {
          ownerId: userId,
          score: (existing?.score ?? 0) + 1,
          polygon: dto.polygon ? (dto.polygon as any) : existing?.polygon,
          area: dto.area ?? existing?.area ?? 0,
          lastActivity: new Date(),
        },
        create: {
          h3Index: dto.h3Index,
          ownerId: userId,
          score: 1,
          polygon: dto.polygon ? (dto.polygon as any) : undefined,
          area: dto.area ?? 0,
          lastActivity: new Date(),
        },
      });

      if (previousOwner && previousOwner !== userId) {
        const thief = await tx.user.findUnique({ where: { id: userId }, select: { username: true } });
        await tx.notification.create({
          data: {
            userId: previousOwner,
            type: 'territory_stolen',
            message: `${thief?.username ?? 'Kimdir'} sizning hududingizni tortib oldi!`,
          },
        });
        await tx.user.update({
          where: { id: userId },
          data: { xp: { increment: 50 } },
        });
      } else if (!previousOwner) {
        await tx.user.update({
          where: { id: userId },
          data: { xp: { increment: 20 } },
        });
      }

      return territory;
    });
  }

  async shieldTerritory(userId: string, h3Index: string) {
    const territory = await this.prisma.territory.findUnique({ where: { h3Index } });
    if (!territory || territory.ownerId !== userId) {
      throw new ForbiddenException('You do not own this territory');
    }
    const shieldedUntil = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours
    return this.prisma.territory.update({
      where: { h3Index },
      data: { shieldedUntil, shieldOwnerId: userId },
    });
  }

  async getUserTerritoryStats(userId: string) {
    const territories = await this.prisma.territory.findMany({
      where: { ownerId: userId },
    });
    const totalArea = territories.reduce((sum, t) => sum + (t.area ?? 0), 0);
    const count = territories.length;
    return { count, totalAreaKm2: Math.round(totalArea * 100) / 100 };
  }
}
