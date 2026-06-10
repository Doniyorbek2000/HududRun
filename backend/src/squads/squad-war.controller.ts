import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../guards/admin.guard';
import { SquadWarService } from './squad-war.service';

@Controller('squad-wars')
@UseGuards(JwtAuthGuard)
export class SquadWarController {
  constructor(private squadWarService: SquadWarService) {}

  @Get('current')
  getCurrent() {
    return this.squadWarService.getCurrentWar();
  }

  @Get('history')
  getHistory() {
    return this.squadWarService.getHistory();
  }

  @Post('create')
  @UseGuards(AdminGuard)
  forceCreate() {
    return this.squadWarService.forceCreate();
  }
}
