import { Controller, Get, Patch, Post, Body, Req, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { MarkNotificationDto } from './dto/mark-notification.dto';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('me')
  listMyNotifications(@Req() req: any) {
    return this.notificationsService.listForUser(req.user.id);
  }

  @Patch('read')
  markRead(@Req() req: any, @Body() dto: MarkNotificationDto) {
    return this.notificationsService.markRead(req.user.id, dto.id);
  }

  @Post('read-all')
  @UseGuards(JwtAuthGuard)
  async markAllRead(@Request() req) {
    await this.notificationsService.markAllRead(req.user.id);
    return { success: true };
  }
}
