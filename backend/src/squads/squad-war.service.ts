import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

const WAR_DURATION_MS = 7 * 24 * 60 * 60 * 1000;

function currentWeekStart(now: Date): Date {
  const day = now.getUTCDay(); // 0 = Sunday, 1 = Monday, ...
  const diffToMonday = (day + 6) % 7; // days since most recent Monday
  const start = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  start.setUTCDate(start.getUTCDate() - diffToMonday);
  return start;
}

@Injectable()
export class SquadWarService {
  constructor(private prisma: PrismaService) {}

  private async finalizeWar(warId: string, startDate: Date, endDate: Date) {
    const participants = await this.prisma.squadWarParticipant.findMany({ where: { warId } });
    const squadIds = participants.map(p => p.squadId);

    const allMembers = await this.prisma.squadMember.findMany({
      where: { squadId: { in: squadIds } },
      select: { squadId: true, userId: true },
    });

    const allUserIds = allMembers.map(m => m.userId);
    const activities = allUserIds.length > 0
      ? await this.prisma.activity.groupBy({
          by: ['userId'],
          where: { userId: { in: allUserIds }, createdAt: { gte: startDate, lt: endDate } },
          _sum: { distance: true },
        })
      : [];

    const distanceByUser = new Map(activities.map(a => [a.userId, a._sum.distance ?? 0]));
    const squadScores = new Map<string, number>();
    for (const member of allMembers) {
      const current = squadScores.get(member.squadId) ?? 0;
      squadScores.set(member.squadId, current + (distanceByUser.get(member.userId) ?? 0));
    }

    let winnerId: string | null = null;
    let topScore = -1;

    for (const p of participants) {
      const score = Math.round((squadScores.get(p.squadId) ?? 0) * 100) / 100;
      await this.prisma.squadWarParticipant.update({
        where: { id: p.id },
        data: { score },
      });
      if (score > topScore) {
        topScore = score;
        winnerId = p.squadId;
      }
    }

    await this.prisma.squadWar.update({
      where: { id: warId },
      data: { status: 'completed', winnerId: topScore > 0 ? winnerId : null },
    });
  }

  private async createWar(startDate: Date, endDate: Date) {
    const squads = await this.prisma.squad.findMany({ select: { id: true } });
    return this.prisma.squadWar.create({
      data: {
        startDate,
        endDate,
        status: 'active',
        participants: {
          create: squads.map((s) => ({ squadId: s.id, score: 0 })),
        },
      },
      include: { participants: true },
    });
  }

  async getCurrentWar() {
    const now = new Date();
    const weekStart = currentWeekStart(now);
    const weekEnd = new Date(weekStart.getTime() + WAR_DURATION_MS);

    let war = await this.prisma.squadWar.findFirst({ orderBy: { createdAt: 'desc' } });

    if (!war || war.endDate <= now) {
      if (war && war.status === 'active') {
        await this.finalizeWar(war.id, war.startDate, war.endDate);
      }
      await this.createWar(weekStart, weekEnd);
      war = await this.prisma.squadWar.findFirst({ orderBy: { createdAt: 'desc' } });
    }

    return this.buildWarResponse(war!);
  }

  async getHistory() {
    const wars = await this.prisma.squadWar.findMany({
      where: { status: 'completed' },
      orderBy: { endDate: 'desc' },
      take: 10,
      include: {
        winner: { select: { id: true, name: true, tag: true, color: true } },
        participants: {
          include: { squad: { select: { id: true, name: true, tag: true, color: true } } },
        },
      },
    });

    return wars.map((w) => ({
      id: w.id,
      startDate: w.startDate,
      endDate: w.endDate,
      winner: w.winner,
      participants: w.participants
        .map((p) => ({
          squadId: p.squadId,
          name: p.squad.name,
          tag: p.squad.tag,
          color: p.squad.color,
          score: p.score,
        }))
        .sort((a, b) => b.score - a.score)
        .map((p, i) => ({ ...p, rank: i + 1 })),
    }));
  }

  async forceCreate() {
    const now = new Date();
    const weekStart = currentWeekStart(now);
    const weekEnd = new Date(weekStart.getTime() + WAR_DURATION_MS);

    const active = await this.prisma.squadWar.findFirst({
      where: { status: 'active' },
      orderBy: { createdAt: 'desc' },
    });
    if (active) {
      await this.finalizeWar(active.id, active.startDate, active.endDate);
    }

    const war = await this.createWar(weekStart, weekEnd);
    return this.buildWarResponse(war);
  }

  private async buildWarResponse(war: { id: string; startDate: Date; endDate: Date; status: string }) {
    const participants = await this.prisma.squadWarParticipant.findMany({
      where: { warId: war.id },
      include: {
        squad: {
          select: { id: true, name: true, tag: true, color: true },
        },
      },
    });

    const squadIds = participants.map(p => p.squadId);

    // Get all members for all squads in one query
    const allMembers = await this.prisma.squadMember.findMany({
      where: { squadId: { in: squadIds } },
      select: { squadId: true, userId: true },
    });

    const allUserIds = allMembers.map(m => m.userId);

    // Get all activities for all users in one query
    const activities = allUserIds.length > 0
      ? await this.prisma.activity.groupBy({
          by: ['userId'],
          where: {
            userId: { in: allUserIds },
            createdAt: { gte: war.startDate, lt: new Date() },
          },
          _sum: { distance: true },
        })
      : [];

    const distanceByUser = new Map(activities.map(a => [a.userId, a._sum.distance ?? 0]));

    // Build a map of squadId -> total distance
    const squadScores = new Map<string, number>();
    for (const member of allMembers) {
      const current = squadScores.get(member.squadId) ?? 0;
      squadScores.set(member.squadId, current + (distanceByUser.get(member.userId) ?? 0));
    }

    const ranked = participants
      .map(p => ({
        squadId: p.squadId,
        name: p.squad.name,
        tag: p.squad.tag,
        color: p.squad.color,
        score: Math.round((squadScores.get(p.squadId) ?? 0) * 100) / 100,
      }))
      .sort((a, b) => b.score - a.score)
      .map((p, i) => ({ ...p, rank: i + 1 }));

    return {
      id: war.id,
      startDate: war.startDate,
      endDate: war.endDate,
      status: war.status,
      timeRemainingMs: Math.max(0, war.endDate.getTime() - Date.now()),
      participants: ranked,
    };
  }
}
