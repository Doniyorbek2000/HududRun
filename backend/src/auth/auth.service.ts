import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma.service';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(username: string, phone: string | undefined, password: string) {
    const existing = await this.prisma.user.findFirst({
      where: { OR: [{ username }, { phone }] },
    });

    if (existing) {
      throw new BadRequestException('Username or phone already in use');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userCount = await this.prisma.user.count();
    const colorPalette = [
      '#7C3AED', '#2563EB', '#059669', '#D97706',
      '#DC2626', '#DB2777', '#0891B2', '#F59E0B',
      '#10B981', '#6366F1', '#EF4444', '#8B5CF6',
    ];
    const color = colorPalette[userCount % colorPalette.length];
    const user = await this.prisma.user.create({
      data: { username, phone, password: hashedPassword, color },
    });
    return this.generateTokens(user.id);
  }

  async login(username: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { username } });
    if (!user || !(await bcrypt.compare(password, user.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return this.generateTokens(user.id);
  }

  async validateUser(username: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { username } });
    if (!user || !(await bcrypt.compare(password, user.password))) {
      return null;
    }
    return user;
  }

  async refresh(refreshToken: string) {
    const stored = await this.prisma.refreshToken.findUnique({
      where: { token: refreshToken },
    });

    if (!stored || stored.expiresAt < new Date()) {
      throw new UnauthorizedException('Refresh token invalid or expired');
    }

    const payload = { sub: stored.userId };
    const accessToken = this.jwtService.sign(payload);
    return { accessToken };
  }

  async logout(refreshToken: string) {
    await this.prisma.refreshToken.deleteMany({ where: { token: refreshToken } });
    return { success: true };
  }

  private async generateTokens(userId: string) {
    const payload = { sub: userId };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });
    await this.prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });
    return { accessToken, refreshToken };
  }
}