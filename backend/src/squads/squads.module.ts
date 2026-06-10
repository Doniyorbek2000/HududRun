import { Module } from '@nestjs/common';
import { SquadsController } from './squads.controller';
import { SquadsService } from './squads.service';
import { SquadWarController } from './squad-war.controller';
import { SquadWarService } from './squad-war.service';
import { PrismaService } from '../prisma.service';
import { AdminGuard } from '../guards/admin.guard';

@Module({
  controllers: [SquadsController, SquadWarController],
  providers: [SquadsService, SquadWarService, PrismaService, AdminGuard],
  exports: [SquadsService],
})
export class SquadsModule {}
