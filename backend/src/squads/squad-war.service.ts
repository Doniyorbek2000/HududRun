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

  private async scoreSquad(squadId: string, start: Date, end: Date): Promise<number> {
    const members = await this.prisma.squadMember.findMany({
      where: { squadId },
      select: { userId: true },
    });
    const userIds = members.map((m) => m.userId);
    if (userIds.length === 0) return 0;

    const result = await this.prisma.activity.aggregate({
      where: { userId: { in: userIds }, createdAt: { gte: start, lt: end } },
      _sum: { distance: true },
    });
    return Math.round((result._sum.distance ?? 0) * 100) / 100;
  }

  private async finalizeWar(warId: string, startDate: Date, endDate: Date) {
    const participants = await this.prisma.squadWarParticipant.findMany({ where: { warId } });

    let winnerId: string | null = null;
    let topScore = -1;

    for (const p of participants) {
      const score = await this.scoreSquad(p.squadId, startDate, endDate);
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
      include: { squad: { select: { id: true, name: true, tag: true, color: true } } },
    });

    const ranked = await Promise.all(
      participants.map(async (p) => ({
        squadId: p.squadId,
        name: p.squad.name,
        tag: p.squad.tag,
        color: p.squad.color,
        score: await this.scoreSquad(p.squadId, war.startDate, new Date()),
      })),
    );

    ranked.sort((a, b) => b.score - a.score);
    const withRank = ranked.map((p, i) => ({ ...p, rank: i + 1 }));

    return {
      id: war.id,
      startDate: war.startDate,
      endDate: war.endDate,
      status: war.status,
      timeRemainingMs: Math.max(0, war.endDate.getTime() - Date.now()),
      participants: withRank,
    };
  }
}
