import { IsDateString, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateChallengeDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsString()
  @IsNotEmpty()
  type: string;

  @IsNumber()
  target: number;

  @IsDateString()
  startDate: string;

  @IsDateString()
  endDate: string;
}
