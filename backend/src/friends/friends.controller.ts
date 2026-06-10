import { Controller, Get, Post, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { FriendsService } from './friends.service';
import { SendFriendRequestDto, FriendActionDto } from './dto/friend-request.dto';

@Controller('friends')
@UseGuards(JwtAuthGuard)
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Post('request')
  requestFriend(@Req() req: any, @Body() dto: SendFriendRequestDto) {
    return this.friendsService.sendRequest(req.user.id, dto);
  }

  @Post('accept')
  acceptFriend(@Req() req: any, @Body() dto: FriendActionDto) {
    return this.friendsService.acceptRequest(req.user.id, dto);
  }

  @Post('remove')
  removeFriend(@Req() req: any, @Body() dto: FriendActionDto) {
    return this.friendsService.removeFriend(req.user.id, dto);
  }

  @Get('pending')
  getPending(@Req() req: any) {
    return this.friendsService.getPending(req.user.id);
  }

  @Get()
  listFriends(@Req() req: any) {
    return this.friendsService.list(req.user.id);
  }
}
