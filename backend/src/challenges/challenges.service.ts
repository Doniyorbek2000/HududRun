import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateChallengeDto } from './dto/create-challenge.dto';
import { JoinChallengeDto } from './dto/join-challenge.dto';

@Injectable()
export class ChallengesService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateChallengeDto) {
    return this.prisma.challenge.create({
      data: {
        creatorId: userId,
        title: dto.title,
        description: dto.description,
        type: dto.type,
        target: dto.target,
        startDate: new Date(dto.startDate),
        endDate: new Date(dto.endDate),
      },
    });
  }

  async join(userId: string, dto: JoinChallengeDto) {
    const challenge = await this.prisma.challenge.findUnique({
      where: { id: dto.challengeId },
    });

    if (!challenge) {
      throw new NotFoundException('Challenge not found');
    }

    const existing = await this.prisma.challengeParticipant.findUnique({
      where: { challengeId_userId: { challengeId: dto.challengeId, userId } },
    });

    if (existing) {
      throw new BadRequestException('Already joined challenge');
    }

    return this.prisma.challengeParticipant.create({
      data: {
        challengeId: dto.challengeId,
        userId,
      },
    });
  }

  async listAvailable() {
    return this.prisma.challenge.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async listForUser(userId: string) {
    return this.prisma.challengeParticipant.findMany({
      where: { userId },
      include: { challenge: true },
      orderBy: { joinedAt: 'desc' },
    });
  }
}
