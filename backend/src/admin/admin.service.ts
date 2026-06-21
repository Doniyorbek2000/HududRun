import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async getDashboard() {
    const [userCount, territoryCount, activityCount, squadCount, activeToday] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.territory.count({ where: { ownerId: { not: null } } }),
      this.prisma.activity.count(),
      this.prisma.squad.count(),
      this.prisma.activity.count({
        where: { createdAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } },
      }),
    ]);

    const topUsers = await this.prisma.user.findMany({
      select: { id: true, username: true, xp: true, level: true, isAdmin: true },
      orderBy: { xp: 'desc' },
      take: 5,
    });

    return { userCount, territoryCount, activityCount, squadCount, activeToday, topUsers };
  }

  async getUsers(page = 1, limit = 20, search?: string) {
    const skip = (page - 1) * limit;
    const where = search
      ? { OR: [{ username: { contains: search, mode: 'insensitive' as const } }] }
      : {};

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        select: {
          id: true, username: true, phone: true, level: true, xp: true,
          isPremium: true, isAdmin: true, country: true, region: true,
          createdAt: true, streak: true,
          _count: { select: { territories: true, activities: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.user.count({ where }),
    ]);

    return { users, total, page, pages: Math.ceil(total / limit) };
  }

  async updateUser(id: string, data: { isPremium?: boolean; isAdmin?: boolean; level?: number; xp?: number }) {
    return this.prisma.user.update({
      where: { id },
      data,
      select: { id: true, username: true, isPremium: true, isAdmin: true, level: true, xp: true },
    });
  }

  async deleteUser(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    await this.prisma.user.delete({ where: { id } });
    return { success: true };
  }

  async getTerritories(page = 1, limit = 50) {
    const skip = (page - 1) * limit;
    const [territories, total] = await Promise.all([
      this.prisma.territory.findMany({
        include: { owner: { select: { id: true, username: true } } },
        orderBy: { lastActivity: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.territory.count(),
    ]);
    return { territories, total, page };
  }

  async deleteTerritory(id: string) {
    const territory = await this.prisma.territory.findUnique({ where: { id } });
    if (!territory) throw new NotFoundException('Territory not found');
    await this.prisma.territory.delete({ where: { id } });
    return { success: true };
  }

  async getSquads(page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    const [squads, total] = await Promise.all([
      this.prisma.squad.findMany({
        include: {
          captain: { select: { username: true } },
          _count: { select: { members: true } },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.squad.count(),
    ]);
    return { squads, total, page };
  }

  async deleteSquad(id: string) {
    const squad = await this.prisma.squad.findUnique({ where: { id } });
    if (!squad) throw new NotFoundException('Squad not found');
    await this.prisma.squad.delete({ where: { id } });
    return { success: true };
  }

  async broadcastNotification(message: string, type = 'system') {
    const users = await this.prisma.user.findMany({ select: { id: true } });
    await this.prisma.notification.createMany({
      data: users.map(u => ({ userId: u.id, type, message })),
    });
    return { sent: users.length };
  }

  async getActivities(page = 1, limit = 50) {
    const skip = (page - 1) * limit;
    const [activities, total] = await Promise.all([
      this.prisma.activity.findMany({
        include: { user: { select: { username: true } } },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.activity.count(),
    ]);
    return { activities, total, page };
  }

  async getStats() {
    const now = new Date();
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const [
      newUsersWeek, newUsersMonth,
      activitiesWeek, activitiesMonth,
      premiumCount,
    ] = await Promise.all([
      this.prisma.user.count({ where: { createdAt: { gte: weekAgo } } }),
      this.prisma.user.count({ where: { createdAt: { gte: monthAgo } } }),
      this.prisma.activity.count({ where: { createdAt: { gte: weekAgo } } }),
      this.prisma.activity.count({ where: { createdAt: { gte: monthAgo } } }),
      this.prisma.user.count({ where: { isPremium: true } }),
    ]);

    return { newUsersWeek, newUsersMonth, activitiesWeek, activitiesMonth, premiumCount };
  }
}
