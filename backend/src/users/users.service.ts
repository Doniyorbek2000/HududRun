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
        level: true,
        xp: true,
        isPremium: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }
}
