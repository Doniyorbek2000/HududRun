import { IsNotEmpty, IsString } from 'class-validator';

export class JoinChallengeDto {
  @IsString()
  @IsNotEmpty()
  challengeId: string;
}
