import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getLeaderboard(filters?: { country?: string; region?: string; district?: string }) {
    const where: any = {};
    if (filters?.country) where.country = filters.country;
    if (filters?.region) where.region = filters.region;
    if (filters?.district) where.district = filters.district;

    const users = await this.prisma.user.findMany({
      where,
      select: {
        id: true,
        username: true,
        color: true,
        level: true,
        xp: true,
        isPremium: true,
        country: true,
        region: true,
        district: true,
        _count: { select: { territories: true } },
      },
      orderBy: { xp: 'desc' },
      take: 50,
    });

    return users.map((u, index) => ({
      rank: index + 1,
      id: u.id,
      username: u.username,
      color: u.color,
      level: u.level,
      xp: u.xp,
      isPremium: u.isPremium,
      country: u.country,
      region: u.region,
      district: u.district,
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
        avatar: true,
        country: true,
        region: true,
        district: true,
        bio: true,
        streak: true,
        lastRunDate: true,
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
        avatar: true,
        country: true,
        region: true,
        district: true,
        bio: true,
        streak: true,
        lastRunDate: true,
        level: true,
        xp: true,
        isPremium: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async getWeeklyLeaderboard() {
    const oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const activities = await this.prisma.activity.groupBy({
      by: ['userId'],
      where: { createdAt: { gte: oneWeekAgo } },
      _sum: { distance: true },
      _count: { id: true },
      orderBy: { _sum: { distance: 'desc' } },
      take: 20,
    });

    const userIds = activities.map(a => a.userId);
    const users = await this.prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, username: true, level: true, color: true },
    });
    const userMap = new Map(users.map(u => [u.id, u]));

    return activities.map((a, i) => ({
      rank: i + 1,
      userId: a.userId,
      username: userMap.get(a.userId)?.username ?? 'Unknown',
      level: userMap.get(a.userId)?.level ?? 1,
      color: userMap.get(a.userId)?.color ?? '#ADC6FF',
      weeklyDistance: Math.round((a._sum.distance ?? 0) * 100) / 100,
      runCount: a._count.id,
    }));
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

  async getSquadLeaderboard() {
    const squads = await this.prisma.squad.findMany({
      include: {
        members: {
          include: {
            user: {
              select: { xp: true, color: true, _count: { select: { territories: true } } },
            },
          },
        },
        captain: {
          select: { username: true, color: true },
        },
      },
    });

    const ranked = squads
      .map((squad) => {
        const totalXp = squad.members.reduce((sum, m) => sum + m.user.xp, 0);
        const totalTerritories = squad.members.reduce(
          (sum, m) => sum + m.user._count.territories,
          0,
        );
        return {
          id: squad.id,
          name: squad.name,
          tag: squad.tag,
          color: squad.color,
          captainName: squad.captain.username,
          memberCount: squad.members.length,
          totalXp,
          totalTerritories,
        };
      })
      .sort((a, b) => b.totalXp - a.totalXp)
      .map((s, i) => ({ ...s, rank: i + 1 }));

    return ranked;
  }
}
