import { Module } from '@nestjs/common';
import { TerritoriesService } from './territories.service';
import { TerritoriesController } from './territories.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  providers: [TerritoriesService],
  controllers: [TerritoriesController],
})
export class TerritoriesModule {}
