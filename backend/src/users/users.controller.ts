import { Controller, Get, Patch, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('leaderboard')
  getLeaderboard() {
    return this.usersService.getLeaderboard();
  }

  @Get('me')
  getProfile(@Req() req: any) {
    return this.usersService.findOne(req.user.id);
  }

  @Get('me/territory-stats')
  getTerritoryStats(@Req() req: any) {
    return this.usersService.getTerritoryStats(req.user.id);
  }

  @Patch('me')
  updateProfile(@Req() req: any, @Body() dto: UpdateUserDto) {
    return this.usersService.update(req.user.id, dto);
  }
}
