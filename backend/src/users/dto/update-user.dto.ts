import { IsOptional, IsString, IsBoolean, IsInt, Min } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  username?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsBoolean()
  isPremium?: boolean;

  @IsOptional()
  @IsInt()
  @Min(0)
  xp?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  level?: number;
}
