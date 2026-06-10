import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { ActivitiesModule } from './activities/activities.module';
import { TerritoriesModule } from './territories/territories.module';
import { PaymentsModule } from './payments/payments.module';
import { FriendsModule } from './friends/friends.module';
import { ChallengesModule } from './challenges/challenges.module';
import { NotificationsModule } from './notifications/notifications.module';
import { SquadsModule } from './squads/squads.module';
import { AdminModule } from './admin/admin.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    AuthModule,
    UsersModule,
    ActivitiesModule,
    TerritoriesModule,
    PaymentsModule,
    FriendsModule,
    ChallengesModule,
    NotificationsModule,
    SquadsModule,
    AdminModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
