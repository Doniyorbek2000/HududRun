import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { FriendRequestDto } from './dto/friend-request.dto';

@Injectable()
export class FriendsService {
  constructor(private prisma: PrismaService) {}

  async sendRequest(userId: string, dto: FriendRequestDto) {
    if (userId === dto.friendId) {
      throw new BadRequestException('Cannot add yourself as a friend');
    }

    const existing = await this.prisma.friend.findUnique({
      where: { userId_friendId: { userId, friendId: dto.friendId } },
    });

    if (existing) {
      throw new BadRequestException('Friend request already exists');
    }

    return this.prisma.friend.create({
      data: {
        userId,
        friendId: dto.friendId,
        status: 'pending',
      },
    });
  }

  async acceptRequest(userId: string, dto: FriendRequestDto) {
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

  async list(userId: string) {
    return this.prisma.friend.findMany({
      where: {
        OR: [
          { userId, status: 'accepted' },
          { friendId: userId, status: 'accepted' },
        ],
      },
      include: { user: true, friend: true },
    });
  }
}
