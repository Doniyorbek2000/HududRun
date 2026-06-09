import { Controller, Get, Post, Delete, Param, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SquadsService } from './squads.service';
import { CreateSquadDto } from './dto/create-squad.dto';

@Controller('squads')
export class SquadsController {
  constructor(private squadsService: SquadsService) {}

  @Get()
  findAll() {
    return this.squadsService.findAll();
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  mySquad(@Req() req: any) {
    return this.squadsService.mySquad(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.squadsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Req() req: any, @Body() dto: CreateSquadDto) {
    return this.squadsService.create(req.user.id, dto);
  }

  @Post(':id/join')
  @UseGuards(JwtAuthGuard)
  join(@Req() req: any, @Param('id') id: string) {
    return this.squadsService.join(req.user.id, id);
  }

  @Delete(':id/leave')
  @UseGuards(JwtAuthGuard)
  leave(@Req() req: any, @Param('id') id: string) {
    return this.squadsService.leave(req.user.id, id);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  delete(@Req() req: any, @Param('id') id: string) {
    return this.squadsService.delete(req.user.id, id);
  }
}
