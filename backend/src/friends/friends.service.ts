import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { SendFriendRequestDto, FriendActionDto } from './dto/friend-request.dto';

const FRIEND_PROFILE_SELECT = {
  id: true,
  username: true,
  color: true,
  level: true,
  xp: true,
  isPremium: true,
  country: true,
};

@Injectable()
export class FriendsService {
  constructor(private prisma: PrismaService) {}

  async sendRequest(userId: string, dto: SendFriendRequestDto) {
    const target = await this.prisma.user.findUnique({
      where: { username: dto.username },
      select: { id: true },
    });

    if (!target) {
      throw new NotFoundException('User not found');
    }

    if (target.id === userId) {
      throw new BadRequestException('Cannot add yourself as a friend');
    }

    const existing = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId, friendId: target.id },
          { userId: target.id, friendId: userId },
        ],
      },
    });

    if (existing) {
      throw new BadRequestException('Friend request already exists');
    }

    return this.prisma.friend.create({
      data: {
        userId,
        friendId: target.id,
        status: 'pending',
      },
    });
  }

  async acceptRequest(userId: string, dto: FriendActionDto) {
    const request = await this.prisma.friend.findUnique({
      where: { userId_friendId: { userId: dto.friendId, friendId: userId } },
    });

    if (!request || request.status !== 'pending') {
      throw new NotFoundException('Friend request not found');
    }

    return this.prisma.friend.update({
      where: { id: request.id },
      data: { status: 'accepted' },
    });
  }

  async removeFriend(userId: string, dto: FriendActionDto) {
    await this.prisma.friend.deleteMany({
      where: {
        OR: [
          { userId, friendId: dto.friendId },
          { userId: dto.friendId, friendId: userId },
        ],
      },
    });
    return { success: true };
  }

  async getPending(userId: string) {
    const requests = await this.prisma.friend.findMany({
      where: { friendId: userId, status: 'pending' },
      include: { user: { select: FRIEND_PROFILE_SELECT } },
    });

    return requests.map((r) => ({ ...r.user, requestId: r.id }));
  }

  async list(userId: string) {
    const friendships = await this.prisma.friend.findMany({
      where: {
        OR: [
          { userId, status: 'accepted' },
          { friendId: userId, status: 'accepted' },
        ],
      },
      include: {
        user: { select: FRIEND_PROFILE_SELECT },
        friend: { select: FRIEND_PROFILE_SELECT },
      },
    });

    return friendships.map((f) => (f.userId === userId ? f.friend : f.user));
  }
}
