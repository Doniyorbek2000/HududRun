import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

// Note: isPremium, xp and level are intentionally NOT exposed here.
// Those fields must only change via server-side game logic (territory
// capture, payments) or the dedicated admin endpoints - never via user
// self-update, otherwise a user could grant themselves premium/XP directly.
export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(30)
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
}
