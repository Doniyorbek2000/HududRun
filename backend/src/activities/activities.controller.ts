import { Controller, Get, Post, Body, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ActivitiesService } from './activities.service';
import { CreateActivityDto } from './dto/create-activity.dto';

@Controller('activities')
@UseGuards(JwtAuthGuard)
export class ActivitiesController {
  constructor(private readonly activitiesService: ActivitiesService) {}

  @Post()
  createActivity(@Req() req: any, @Body() dto: CreateActivityDto) {
    return this.activitiesService.create(req.user.id, dto);
  }

  @Get('me')
  getMyActivities(@Req() req: any) {
    return this.activitiesService.findByUser(req.user.id);
  }
}
