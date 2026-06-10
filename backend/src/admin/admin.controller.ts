import {
  Controller, Get, Patch, Delete, Post, Param, Body,
  UseGuards, Query, ParseIntPipe, DefaultValuePipe,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../guards/admin.guard';
import { AdminService } from './admin.service';

@Controller('admin')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get('dashboard')
  getDashboard() {
    return this.adminService.getDashboard();
  }

  @Get('stats')
  getStats() {
    return this.adminService.getStats();
  }

  // Users
  @Get('users')
  getUsers(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
    @Query('search') search?: string,
  ) {
    return this.adminService.getUsers(page, limit, search);
  }

  @Patch('users/:id')
  updateUser(
    @Param('id') id: string,
    @Body() body: { isPremium?: boolean; isAdmin?: boolean; level?: number; xp?: number },
  ) {
    return this.adminService.updateUser(id, body);
  }

  @Delete('users/:id')
  deleteUser(@Param('id') id: string) {
    return this.adminService.deleteUser(id);
  }

  // Territories
  @Get('territories')
  getTerritories(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
  ) {
    return this.adminService.getTerritories(page);
  }

  @Delete('territories/:id')
  deleteTerritory(@Param('id') id: string) {
    return this.adminService.deleteTerritory(id);
  }

  // Squads
  @Get('squads')
  getSquads(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
  ) {
    return this.adminService.getSquads(page);
  }

  @Delete('squads/:id')
  deleteSquad(@Param('id') id: string) {
    return this.adminService.deleteSquad(id);
  }

  // Activities
  @Get('activities')
  getActivities(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
  ) {
    return this.adminService.getActivities(page);
  }

  // Broadcast notification
  @Post('notify')
  broadcastNotification(@Body() body: { message: string; type?: string }) {
    return this.adminService.broadcastNotification(body.message, body.type);
  }
}
