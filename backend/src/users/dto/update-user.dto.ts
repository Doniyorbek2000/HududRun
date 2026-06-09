import { IsOptional, IsString, IsBoolean, IsInt, Min, MaxLength } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  username?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  avatar?: string;  // base64 data URL

  @IsOptional()
  @IsString()
  @MaxLength(2)
  country?: string;  // ISO country code e.g. 'UZ', 'RU'

  @IsOptional()
  @IsString()
  @MaxLength(200)
  bio?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  region?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  district?: string;

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
