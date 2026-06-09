import { Controller, Get, Post, Body, Param, Req, UseGuards, ForbiddenException } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { TerritoriesService } from './territories.service';
import { ClaimTerritoryDto } from './dto/claim-territory.dto';

@Controller('territories')
export class TerritoriesController {
  constructor(private readonly territoriesService: TerritoriesService) {}

  @Get()
  listTerritories() {
    return this.territoriesService.listAll();
  }

  @Get('my/stats')
  @UseGuards(JwtAuthGuard)
  myStats(@Req() req: any) {
    return this.territoriesService.getUserTerritoryStats(req.user.id);
  }

  @Get(':h3Index')
  getTerritory(@Param('h3Index') h3Index: string) {
    return this.territoriesService.getByIndex(h3Index);
  }

  @Post('claim')
  @UseGuards(JwtAuthGuard)
  claimTerritory(@Req() req: any, @Body() dto: ClaimTerritoryDto) {
    return this.territoriesService.claim(req.user.id, dto);
  }

  @Post('shield')
  @UseGuards(JwtAuthGuard)
  async shield(@Req() req: any, @Body() body: { h3Index: string }) {
    return this.territoriesService.shieldTerritory(req.user.id, body.h3Index);
  }
}
