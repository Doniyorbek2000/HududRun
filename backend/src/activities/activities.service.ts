import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';
import { CreateActivityDto } from './dto/create-activity.dto';

@Injectable()
export class ActivitiesService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateActivityDto) {
    const activity = await this.prisma.activity.create({
      data: {
        userId,
        distance: dto.distance,
        duration: dto.duration,
        startTime: new Date(dto.startTime),
        endTime: dto.endTime ? new Date(dto.endTime) : undefined,
        route: dto.route ? (dto.route as any) : undefined,
      },
    });

    // Update streak
    const user = await this.prisma.user.findUnique({ where: { id: userId }, select: { streak: true, lastRunDate: true } });
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const lastRun = user?.lastRunDate ? new Date(user.lastRunDate.getFullYear(), user.lastRunDate.getMonth(), user.lastRunDate.getDate()) : null;
    const yesterday = new Date(today); yesterday.setDate(today.getDate() - 1);

    let newStreak = 1;
    if (lastRun) {
      if (lastRun.getTime() === today.getTime()) {
        newStreak = user!.streak; // same day, no change
      } else if (lastRun.getTime() === yesterday.getTime()) {
        newStreak = (user!.streak || 0) + 1; // consecutive day
      }
      // else streak resets to 1
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: { streak: newStreak, lastRunDate: now },
    });

    return activity;
  }

  async findByUser(userId: string) {
    return this.prisma.activity.findMany({
      where: { userId },
      orderBy: { startTime: 'desc' },
    });
  }
}
