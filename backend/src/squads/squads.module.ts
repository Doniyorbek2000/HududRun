import { Module } from '@nestjs/common';
import { SquadsController } from './squads.controller';
import { SquadsService } from './squads.service';
import { PrismaService } from '../prisma.service';

@Module({
  controllers: [SquadsController],
  providers: [SquadsService, PrismaService],
  exports: [SquadsService],
})
export class SquadsModule {}
