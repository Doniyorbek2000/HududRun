import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getLeaderboard() {
    const users = await this.prisma.user.findMany({
      select: {
        id: true,
        username: true,
        level: true,
        xp: true,
        isPremium: true,
        _count: {
          select: { territories: true },
        },
      },
      orderBy: { xp: 'desc' },
      take: 50,
    });

    return users.map((u, index) => ({
      rank: index + 1,
      id: u.id,
      username: u.username,
      level: u.level,
      xp: u.xp,
      isPremium: u.isPremium,
      territoryCount: u._count.territories,
    }));
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        username: true,
        phone: true,
        color: true,
        level: true,
        xp: true,
        isPremium: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  async update(id: string, dto: UpdateUserDto) {
    return this.prisma.user.update({
      where: { id },
      data: dto,
      select: {
        id: true,
        username: true,
        phone: true,
        color: true,
        level: true,
        xp: true,
        isPremium: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async getTerritoryStats(userId: string) {
    const territories = await this.prisma.territory.findMany({ where: { ownerId: userId } });
    const totalArea = territories.reduce((sum, t) => sum + (t.area ?? 0), 0);
    return {
      count: territories.length,
      totalAreaKm2: Math.round(totalArea * 100) / 100,
      xp: (await this.prisma.user.findUnique({ where: { id: userId }, select: { xp: true } }))?.xp ?? 0,
    };
  }
}
