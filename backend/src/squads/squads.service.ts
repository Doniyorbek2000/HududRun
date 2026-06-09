import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateSquadDto } from './dto/create-squad.dto';

const COLOR_PALETTE = [
  '#7C3AED', '#2563EB', '#059669', '#D97706',
  '#DC2626', '#DB2777', '#0891B2', '#F59E0B',
];

@Injectable()
export class SquadsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateSquadDto) {
    const existing = await this.prisma.squad.findFirst({
      where: { OR: [{ name: dto.name }, { tag: dto.tag }] },
    });
    if (existing) throw new BadRequestException('Squad name or tag already taken');

    const count = await this.prisma.squad.count();
    const color = COLOR_PALETTE[count % COLOR_PALETTE.length];

    const squad = await this.prisma.squad.create({
      data: {
        name: dto.name,
        tag: dto.tag,
        color,
        isPublic: dto.isPublic ?? true,
        captainId: userId,
      },
    });

    await this.prisma.squadMember.create({
      data: { squadId: squad.id, userId, role: 'captain' },
    });

    return this.findOne(squad.id);
  }

  async findAll() {
    const squads = await this.prisma.squad.findMany({
      include: {
        captain: { select: { id: true, username: true, color: true } },
        members: {
          include: { user: { select: { id: true, username: true, level: true, xp: true, color: true } } },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    return squads.map((s) => ({
      ...s,
      memberCount: s.members.length,
    }));
  }

  async findOne(id: string) {
    const squad = await this.prisma.squad.findUnique({
      where: { id },
      include: {
        captain: { select: { id: true, username: true, color: true, level: true } },
        members: {
          include: {
            user: { select: { id: true, username: true, level: true, xp: true, color: true } },
          },
          orderBy: { joinedAt: 'asc' },
        },
      },
    });
    if (!squad) throw new NotFoundException('Squad not found');
    return squad;
  }

  async join(userId: string, squadId: string) {
    const squad = await this.prisma.squad.findUnique({ where: { id: squadId } });
    if (!squad) throw new NotFoundException('Squad not found');

    const existing = await this.prisma.squadMember.findUnique({
      where: { squadId_userId: { squadId, userId } },
    });
    if (existing) throw new BadRequestException('Already a member');

    return this.prisma.squadMember.create({
      data: { squadId, userId, role: 'member' },
    });
  }

  async leave(userId: string, squadId: string) {
    const squad = await this.prisma.squad.findUnique({ where: { id: squadId } });
    if (!squad) throw new NotFoundException('Squad not found');
    if (squad.captainId === userId) throw new BadRequestException('Captain cannot leave. Transfer ownership or delete squad.');

    await this.prisma.squadMember.delete({
      where: { squadId_userId: { squadId, userId } },
    });
    return { success: true };
  }

  async delete(userId: string, squadId: string) {
    const squad = await this.prisma.squad.findUnique({ where: { id: squadId } });
    if (!squad) throw new NotFoundException('Squad not found');
    if (squad.captainId !== userId) throw new ForbiddenException('Only captain can delete squad');

    await this.prisma.squad.delete({ where: { id: squadId } });
    return { success: true };
  }

  async mySquad(userId: string) {
    const membership = await this.prisma.squadMember.findFirst({
      where: { userId },
      include: {
        squad: {
          include: {
            captain: { select: { id: true, username: true, color: true } },
            members: {
              include: {
                user: { select: { id: true, username: true, level: true, xp: true, color: true } },
              },
            },
          },
        },
      },
    });
    if (!membership) return null;
    return membership.squad;
  }
}
