import { Controller, Get, Patch, Body, Req, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('leaderboard')
  getLeaderboard(
    @Query('country') country?: string,
    @Query('region') region?: string,
    @Query('district') district?: string,
  ) {
    return this.usersService.getLeaderboard(
      country || region || district ? { country, region, district } : undefined,
    );
  }

  @Get('leaderboard/squads')
  getSquadLeaderboard() {
    return this.usersService.getSquadLeaderboard();
  }

  @Get('leaderboard/weekly')
  getWeeklyLeaderboard() {
    return this.usersService.getWeeklyLeaderboard();
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
