import { Controller, Get, Post, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ChallengesService } from './challenges.service';
import { CreateChallengeDto } from './dto/create-challenge.dto';
import { JoinChallengeDto } from './dto/join-challenge.dto';

@Controller('challenges')
export class ChallengesController {
  constructor(private readonly challengesService: ChallengesService) {}

  @Get()
  listChallenges() {
    return this.challengesService.listAvailable();
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  createChallenge(@Req() req: any, @Body() dto: CreateChallengeDto) {
    return this.challengesService.create(req.user.id, dto);
  }

  @Post('join')
  @UseGuards(JwtAuthGuard)
  joinChallenge(@Req() req: any, @Body() dto: JoinChallengeDto) {
    return this.challengesService.join(req.user.id, dto);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  getMyChallenges(@Req() req: any) {
    return this.challengesService.listForUser(req.user.id);
  }
}
