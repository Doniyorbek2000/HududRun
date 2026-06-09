import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';
import { CreateActivityDto } from './dto/create-activity.dto';

@Injectable()
export class ActivitiesService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateActivityDto) {
    return this.prisma.activity.create({
      data: {
        userId,
        distance: dto.distance,
        duration: dto.duration,
        startTime: new Date(dto.startTime),
        endTime: dto.endTime ? new Date(dto.endTime) : undefined,
        route: dto.route ? (dto.route as any) : undefined,
      },
    });
  }

  async findByUser(userId: string) {
    return this.prisma.activity.findMany({
      where: { userId },
      orderBy: { startTime: 'desc' },
    });
  }
}
