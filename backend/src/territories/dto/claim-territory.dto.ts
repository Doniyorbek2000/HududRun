import { IsNotEmpty, IsString, IsOptional, IsNumber, IsArray } from 'class-validator';

export class ClaimTerritoryDto {
  @IsString()
  @IsNotEmpty()
  h3Index: string;

  @IsOptional()
  @IsArray()
  polygon?: Array<{ lat: number; lng: number }>;

  @IsOptional()
  @IsNumber()
  area?: number;
}
