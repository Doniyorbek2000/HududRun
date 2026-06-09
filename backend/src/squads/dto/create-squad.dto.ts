import { IsNotEmpty, IsString, IsBoolean, IsOptional, MaxLength } from 'class-validator';

export class CreateSquadDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(5)
  tag: string;

  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;
}
