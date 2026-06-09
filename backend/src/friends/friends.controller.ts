import { Controller, Get, Post, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FriendsService } from './friends.service';
import { FriendRequestDto } from './dto/friend-request.dto';

@Controller('friends')
@UseGuards(JwtAuthGuard)
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Post('request')
  requestFriend(@Req() req: any, @Body() dto: FriendRequestDto) {
    return this.friendsService.sendRequest(req.user.id, dto);
  }

  @Post('accept')
  acceptFriend(@Req() req: any, @Body() dto: FriendRequestDto) {
    return this.friendsService.acceptRequest(req.user.id, dto);
  }

  @Get()
  listFriends(@Req() req: any) {
    return this.friendsService.list(req.user.id);
  }
}
